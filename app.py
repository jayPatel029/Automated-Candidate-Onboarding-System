from flask import Flask, jsonify, request
from pymongo import MongoClient
import os
import json
import os
import json
import cv2
import pytesseract
import fitz
import re
from PIL import Image, ImageStat
from flask_cors import CORS  # Import CORS
import base64
from dotenv import load_dotenv
load_dotenv()


# Import your existing functions

app = Flask(__name__)
CORS(app)  # Enable CORS for the entire app

# MongoDB Atlas connection
# MONGO_URI = "mongodb+srv://jaysunilpatel2002:OGVtcewPWnCaVHSs@cluster123.2nio9.mongodb.net/?retryWrites=true&w=majority&appName=Cluster123"
MONGO_URI = os.getenv('MONGO_URI')
client = MongoClient(MONGO_URI)
db = client["form_database"]
collection = db["form_data"]



def encode_image_to_base64(image_path):
    """
    Encodes an image file to a Base64 string.
    :param image_path: Path to the image file.
    :return: Base64-encoded string of the image.
    """
    try:
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode('utf-8')
    except Exception as e:
        print(f"Failed to encode image {image_path}: {e}")
        return None



# Image Cropping Function
def is_non_black_image(image):
    """Check if an image is not completely black."""
    stat = ImageStat.Stat(image)
    return max(stat.extrema[0]) > 0  # Check if the maximum pixel value is greater than 0


def extract_images_from_pdf(pdf_path, output_dir="extracted_images"):
    print(f"PDF Path: {pdf_path}, Output Directory: {output_dir}")  # Debug log
    os.makedirs(output_dir, exist_ok=True)
    pdf_document = fitz.open(pdf_path)

    # Define regions for photo and signature
    regions = {
        "photo": {
            "coords": (1730, 16, 2297, 523)
        },
        "signature": {
            "coords": (1495, 2947, 2269, 3295)
        }
    }

    extracted_images = []
    for page_number in range(len(pdf_document)):
        if page_number > 1:  # Process only the first two pages
            print(f"Skipping page {page_number + 1} as it is beyond the first two pages.")  # Debug log
            break

        page = pdf_document[page_number]

        # Render page at high DPI
        pixmap = page.get_pixmap(dpi=300)  # Render at 300 DPI for better quality
        page_image_path = f"{output_dir}/page_{page_number + 1}.png"
        pixmap.save(page_image_path)
        print(f"Saved page {page_number + 1} image at {page_image_path}.")  # Debug log

        for key, value in regions.items():
            if (page_number == 0 and key == "photo") or (page_number == 1 and key == "signature"):
                x0, y0, x1, y1 = value["coords"]
                print(f"Processing {key} on page {page_number + 1} with coords: {x0, y0, x1, y1}.")  # Debug log

                # Crop the region of interest
                image = Image.open(page_image_path)
                cropped_image = image.crop((x0, y0, x1, y1))

                # Validate the cropped image
                if is_non_black_image(cropped_image):
                    cropped_image_path = f"{output_dir}/{key}_cropped.png"
                    cropped_image.save(cropped_image_path)
                    extracted_images.append(cropped_image_path)
                    print(f"Saved cropped {key} image at {cropped_image_path}.")  # Debug log
                else:
                    print(f"Cropped {key} image is completely black. Skipping save.")  # Debug log
    return extracted_images

def process_pdf_to_images(pdf_path, output_dir="processed_pages"):
    """
    Convert PDF to images for each page and save them locally.
    :param pdf_path: Path to the input PDF.
    :param output_dir: Directory to save images.
    :return: List of file paths to the saved images.
    """
    import os
    os.makedirs(output_dir, exist_ok=True)

    # Open the PDF
    pdf_document = fitz.open(pdf_path)
    image_paths = []

    for page_number in range(len(pdf_document)):
        # Limit to 3 pages
        if page_number > 2:
            break

        # Get the page
        page = pdf_document[page_number]

        # Render page to image (resolution: 150 DPI)
        pix = page.get_pixmap(dpi=150)

        # Save image as PNG
        image_path = f"{output_dir}/page_{page_number + 1}.png"
        pix.save(image_path)
        image_paths.append(image_path)

    return image_paths


def preprocess_and_ocr(image_path):
    """
    Preprocess the image and apply OCR.
    :param image_path: Path to the input image.
    :return: Extracted text from the image.
    """
    # Read the image
    img = cv2.imread(image_path)

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Apply thresholding to improve OCR accuracy
    _, thresholded = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY)

    # OCR
    text = pytesseract.image_to_string(thresholded, lang='eng')
    print(f"Extracted Text from {image_path}:\n{text}\n")

    return text



# Cleaning and Parsing
def clean_text(ocr_text):
    cleaned_text = re.sub(r'\s+', ' ', ocr_text).strip()
    return cleaned_text


def parse_qualification_table(ocr_text):
    """
    Parses the educational qualification table from OCR text.
    Automatically assigns numbers to rows and ignores Sr No.
    """
    # Clean the text by normalizing spaces and newlines
    cleaned_text = re.sub(r'\s+', ' ', ocr_text).strip()

    # Define the regex pattern to match rows without Sr No.
    pattern = r'([\w\s]+)\s+([\w\s]+)\s+(\d{2,3})\s+(\d{4})'

    # Create a list to store the parsed data
    table_data = []

    # Use regex to find all matches based on the pattern
    matches = re.findall(pattern, cleaned_text)

    # Process each match and add to the table_data list, with automatic numbering
    for index, match in enumerate(matches, start=1):
        row = {
            "Sr No.": str(index),  # Automatically assign Sr No.
            "Name of the School/ University": match[0].strip(),
            "Qualification": match[1].strip(),
            "% or CGPA": match[2],
            "Pass out Year": match[3]
        }
        table_data.append(row)

    return table_data



def parse_training_details_table(ocr_text):
    """
    Parses the training details table from OCR text, ensuring it only extracts data after the relevant header.
    """
    # Find the section starting with "16. Details of any important training undergone:"
    training_section_match = re.search(r"16\. Details of any important training undergone:(.*?)(?=\s*17\.)", ocr_text, re.DOTALL)
    if not training_section_match:
        return []  # Return an empty list if no training details are found

    training_section = training_section_match.group(1).strip()

    # Normalize spaces for consistent parsing
    training_section = re.sub(r'\s+', ' ', training_section)

    # Define a regex pattern to match rows in the training table
    # Assume 'Program', 'Contents', 'Organized By', and 'Duration' are in that order
    pattern = r'([A-Z\s]+)\s+([A-Z\s]+)\s+([A-Z\s]+)\s+([\d\s\w]+)'

    # Parse rows from the normalized section
    training_data = []
    matches = re.findall(pattern, training_section)
    for match in matches:
        row = {
            "Program": match[0].strip(),
            "Contents": match[1].strip(),
            "Organized By": match[2].strip(),
            "Duration": match[3].strip()
        }
        training_data.append(row)

    return training_data


def parse_family_details_table(ocr_text):
    """
    Parses the family details table from OCR text, filling only existing columns 
    and ensuring relations are matched against predefined values.
    """
    # Predefined relations to ensure the table is structured correctly
    predefined_relations = ["Father/ Mother", "Brothers", "Sisters", "Spouse", "Children"]

    # Match the family section in the OCR text
    family_section_match = re.search(r"18\. Details of Family Members:(.*?)(?=\s*19\.)", ocr_text, re.DOTALL)
    if not family_section_match:
        # Return table with empty "Not Provided" values if no section is found
        return [{"Relation": rel, "Occupation/Profession": "Not Provided", "Resident Location": "Not Provided"} 
                for rel in predefined_relations]

    # Extract the family section
    family_section = family_section_match.group(1).strip()

    # Split rows by predefined relations
    rows = re.split(r'\s*(Father/ Mother|Brothers|Sisters|Spouse|Children)\s+', family_section)
    
    # Dictionary to hold extracted data
    family_data_dict = {}

    # Iterate through rows to parse data
    for i in range(1, len(rows), 2):  # Skip every 2 steps: Relation + Details
        relation = rows[i].strip()  # Get the relation
        details = rows[i + 1].strip()  # Get the corresponding details
        
        # Extract Occupation/Profession and Resident Location
        details_parts = details.split()
        if len(details_parts) >= 2:
            occupation = details_parts[0]
            location = details_parts[1]
        else:
            occupation = details_parts[0] if len(details_parts) == 1 else "Not Provided"
            location = "Not Provided"
        
        family_data_dict[relation] = {
            "Occupation/Profession": occupation,
            "Resident Location": location
        }

    # Fill missing relations with "Not Provided"
    family_data = []
    for relation in predefined_relations:
        if relation in family_data_dict:
            family_data.append({
                "Relation": relation,
                "Occupation/Profession": family_data_dict[relation]["Occupation/Profession"],
                "Resident Location": family_data_dict[relation]["Resident Location"]
            })
        else:
            family_data.append({
                "Relation": relation,
                "Occupation/Profession": "Not Provided",
                "Resident Location": "Not Provided"
            })

    return family_data


def parse_references_table(ocr_text):
    """
    Parses the references table from OCR text.
    """
    references_section_match = re.search(r"19\. References:.*?Name(.*?)(?=\s*\d+\.|$)", ocr_text, re.DOTALL)
    if not references_section_match:
        return []

    references_section = references_section_match.group(1).strip()

    # Normalize spaces for consistent parsing
    references_section = re.sub(r'\s+', ' ', references_section)

    # Define regex pattern to match rows
    pattern = r'([\w\s]+)\s+([\w\s]+)\s+([\w\d\s]+)'

    references_data = []
    matches = re.findall(pattern, references_section)
    for match in matches:
        row = {
            "Name": match[0].strip(),
            "Designation": match[1].strip(),
            "Contact No": match[2].strip()
        }
        references_data.append(row)

    return references_data


def parse_certifications_table(ocr_text):
    """
    Parses the technical/professional certifications table from OCR text.
    Only starts processing if a specific line is found.
    """
    # Clean the text by normalizing spaces and newlines
    cleaned_text = re.sub(r'\s+', ' ', ocr_text).strip()

    # Look for the specific line that indicates the start of the certifications table
    start_line_pattern = r'17\. Please list the technical or professional certification you completed'

    # Check if the pattern exists in the OCR text
    if re.search(start_line_pattern, cleaned_text):
        # Find the part of the text after this line
        start_index = re.search(start_line_pattern, cleaned_text).end()
        certifications_text = cleaned_text[start_index:]

        # Define the regex pattern to match rows for technical certifications
        pattern = r'(\d+)\s+([A-Za-z0-9\s]+?)\s+(\d+\s*(?:WEEKS|MONTHS|YEARS))'

        # Create a list to store the parsed data
        certifications_data = []

        # Use regex to find all matches based on the pattern
        matches = re.findall(pattern, certifications_text)

        # Process each match and add to the certifications_data list
        for match in matches:
            row = {
                "Sr No.": match[0],  # Sr No of the certification
                "Certification": match[1].strip(),  # Name of the certification
                "Duration": match[2].strip()  # Duration of the certification
            }
            certifications_data.append(row)

        return certifications_data
    else:
        return []  # Return an empty list if the line is not found


def parse_complete_form(ocr_text):
    def safe_extract(pattern, text, group_index=1, default="Not Provided"):
        match = re.search(pattern, text, re.IGNORECASE)
        return match.group(group_index).strip() if match else default

    ocr_text = clean_text(ocr_text)
    print("using this of parsing")
    print(ocr_text)

    return {
      "Name": safe_extract(r"1\.\s*Name.*?:\s*([\w\s]+(?:\s[\w\s]+)*)", ocr_text),
      "Permanent Address": {
        "Street Address": safe_extract(r"2\.1\s*Street Address[:\-]?\s*([A-Za-z0-9\s,./-]+?)(?=\s*2\.2\s*City)", ocr_text),
        "City": safe_extract(r"2\.2\s*City[:\-]?\s*([\w\s]+)", ocr_text),
        "State": safe_extract(r"2\.3\s*State[:\-]?\s*([\w\s]+)", ocr_text),
        "Zip Code": safe_extract(r"2\.4\s*Zip Code[:\-]?\s*(\d{6})", ocr_text),
        "Country": safe_extract(r"2\.5\s*Country[:\-]?\s*([\w\s]+)", ocr_text)
      },
      "Current Address": {
        "Street Address": safe_extract(r"3\.1\s*Street Address[:\-]?\s*([A-Za-z0-9\s,./-]+?)(?=\s*3\.2\s*City)", ocr_text),
        "City": safe_extract(r"3\.2\s*City[:\-]?\s*([\w\s]+)", ocr_text),
        "State": safe_extract(r"3\.3\s*State[:\-]?\s*([\w\s]+)", ocr_text),
        "Zip Code": safe_extract(r"3\.4\s*Zip Code[:\-]?\s*(\d{6})", ocr_text),
        "Country": safe_extract(r"3\.5\s*Country[:\-]?\s*([\w\s]+)", ocr_text)
      },
      "Date of Birth": safe_extract(r"4\. Date of Birth:\s*(\d{1,2}\s*/\s*\d{1,2}\s*/\s*\d{4})", ocr_text),
      "Age": safe_extract(r"5\. Age:\s*(\d+)", ocr_text),
      "Gender": safe_extract(r"6\. Gender:\s*(\w+)", ocr_text),
      "Passport": safe_extract(r"7\. Passport:\s*([A-Za-z0-9]+|N/A)", ocr_text),
      "Mobile": safe_extract(r"8\. Mobile:\s*(\+?\d{1,4}[-\s]?\d{10,15})", ocr_text),
      "PAN No": safe_extract(r"9\s*\.?\s*PAN\s*No\.\s*[:\-]?\s*([\w\d]+)", ocr_text),
      "Visa": safe_extract(r"10\. Visa:\s*(.+?)\s*(?=\d|\n|$)", ocr_text),
      "Email ID": safe_extract(r"11\s*[,\.]?\s*Email\s*ID\s*[:\-]?\s*([\w._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})", ocr_text),
      "Emergency Contact Name": safe_extract(r"12\s*\.?\s*Name\s*of\s*Emergency\s*Contact\s*[:\-]?\s*([^13]+)", ocr_text),
      "Emergency Contact Number": safe_extract(r"13\. Emergency Contact's Number:\s*(\+?\d{1,4}[-\s]?\d{10,15})", ocr_text),
      "Available for Relocation": safe_extract(r"14\. Available for Relocation:\s*(\w+)", ocr_text),
      "Educational Qualifications": parse_qualification_table(ocr_text),
      "Training Details": parse_training_details_table(ocr_text),
      "Technical Certifications": parse_certifications_table(ocr_text),
      "Family Details": parse_family_details_table(ocr_text),
      "References": parse_references_table(ocr_text)

    }

# Form Model Class
class FormModel:
    def __init__(self, parsed_data, encoded_images):
        self.data = parsed_data
        self.data['images'] = encoded_images

    def to_json(self):
        return json.dumps(self.data, indent=4)


# Complete Workflow
def process_form(pdf_path):

    print("Converting PDF to Images...")
    image_paths = process_pdf_to_images(pdf_path)

    extracted_text = ""
    print("Performing OCR...")
    for image_path in image_paths:
        page_text = preprocess_and_ocr(image_path)
        extracted_text += f"\n--- Page {image_paths.index(image_path) + 1} ---\n{page_text}"


    print("Parsing OCR Results...")
    parsed_data = parse_complete_form(extracted_text)


    print("Extracting Images from PDF...")
    extracted_images = extract_images_from_pdf(pdf_path)


    encoded_images = []
    # Encode full-page images
    for page_image in image_paths:
        encoded = encode_image_to_base64(page_image)
        if encoded:
            encoded_images.append({
                "type": "page",
                "file_name": os.path.basename(page_image),
                "content": encoded
            })

    # Encode cropped images
    for cropped_image in extracted_images:
        encoded = encode_image_to_base64(cropped_image)
        if encoded:
            encoded_images.append({
                "type": "cropped",
                "file_name": os.path.basename(cropped_image),
                "content": encoded
            })


    print("Creating Form Model...")
    form_model = FormModel(parsed_data, encoded_images)

    # print("Extracting Images from PDF...")
    # extracted_images = extract_images_from_pdf(pdf_path)

    return form_model






# @app.route('/process', methods=['GET'])
# def process_pdf():
#     # Hardcoded PDF path for testing
#     pdf_path = r'C:\Users\jaysu\Desktop\Enzigma_task\form.pdf'  # Adjust the path to your local PDF
#     print(f"Processing PDF: {pdf_path}")

#     try:
#         # Process the form from PDF
#         form_model = process_form(pdf_path)
#         form_json = form_model.to_json()

#         # Print the form JSON
#         print("Parsed Form Data:")
#         print(form_json)

#         # Save the data to MongoDB
#         collection.insert_one(json.loads(form_json))

#         return jsonify({"message": "Form processed successfully", "data": json.loads(form_json)})

#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# # Health check endpoint
# @app.route('/health', methods=['GET'])
# def health_check():
#     try:
#         # Attempt to fetch a single document to verify the connection
#         db_status = client.admin.command('ping')
#         if db_status.get("ok", 0) == 1:
#             return jsonify({"status": "API is running", "mongo": "connected"}), 200
#         else:
#             return jsonify({"status": "API is running", "mongo": "not connected"}), 500
#     except Exception as e:
#         return jsonify({"status": "API is running", "mongo": "connection failed", "error": str(e)}), 500


# if __name__ == '__main__':
#     # Run the Flask app
#     app.run(host='0.0.0.0', port=5000)




# Directory to temporarily store uploaded files
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)



@app.route('/process', methods=['POST'])
def process_pdf():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    uploaded_file = request.files['file']
    if uploaded_file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    # Save the file temporarily
    temp_file_path = os.path.join(UPLOAD_FOLDER, uploaded_file.filename)
    uploaded_file.save(temp_file_path)
    print(f"Received and saved PDF: {temp_file_path}")

    try:
        # Process the form from the uploaded PDF
        form_model = process_form(temp_file_path)  # Replace with your PDF processing function
        form_json = form_model.to_json()

        # Print the parsed form data
        print("Parsed Form Data:")
        print(form_json)

        # Save the data to MongoDB
        collection.insert_one(json.loads(form_json))

        # Clean up the temporary file after processing
        os.remove(temp_file_path)

        return jsonify({"message": "Form processed successfully", "data": json.loads(form_json)})

    except Exception as e:
        # Clean up the temporary file in case of an error
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        return jsonify({"error": str(e)}), 500

# Endpoint to fetch all data from MongoDB
@app.route('/fetch_all_data', methods=['GET'])
def fetch_all_data():
    try:
        # Query all documents in the MongoDB collection
        data = list(collection.find({}, {'_id': 0}))  # Exclude the _id field from results

        # Return the data as JSON
        return jsonify({"message": "Data fetched successfully", "data": data}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    try:
        # Attempt to fetch a single document to verify the connection
        db_status = client.admin.command('ping')
        if db_status.get("ok", 0) == 1:
            return jsonify({"status": "API is running", "mongo": "connected"}), 200
        else:
            return jsonify({"status": "API is running", "mongo": "not connected"}), 500
    except Exception as e:
        return jsonify({"status": "API is running", "mongo": "connection failed", "error": str(e)}), 500

if __name__ == '__main__':
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000)
