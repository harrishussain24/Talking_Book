from flask import Flask, request, jsonify
from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextContainer
from gtts import gTTS
import re
import os
import base64

app = Flask(__name__)

def extract_text_with_page_numbers(pdf_path):
    pages = list(extract_pages(pdf_path))
    text_pages = []

    for page_num, page_layout in enumerate(pages, start=1):
        page_text = ""
        for element in page_layout:
            if isinstance(element, LTTextContainer):
                page_text += element.get_text()
        text_pages.append((page_num, page_text.strip()))

    return text_pages

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file part', 400

    file = request.files['file']
    if file.filename == '':
        return 'No selected file', 400

    # Save the uploaded file
    file.save(file.filename)

    # Extract text by pages
    text_pages = extract_text_with_page_numbers(file.filename)
    
    response_data = []
    for page_num, page_text in text_pages:
        # Clean text
        cleaned_text = re.sub(r'[^\w\s]', '', page_text)
        cleaned_text = re.sub(r'\s+', ' ', cleaned_text)
        
        # Convert text to speech
        tts = gTTS(cleaned_text, lang='en')
        audio_file = f'output_page_{page_num}.mp3'
        tts.save(audio_file)

        # Read the audio file as binary data
        with open(audio_file, 'rb') as audio:
            audio_data = audio.read()

        # Encode the binary audio data into base64
        audio_base64 = base64.b64encode(audio_data).decode('utf-8')

        response_data.append({
            "page": page_num,
            "text": cleaned_text,
            "audio_base64": audio_base64
        })

    # Return the text and audio data for each page
    return jsonify(response_data)

if __name__ == '__main__':
    app.run(debug=True)
