const express = require('express');
const cors = require('cors');
const multer = require('multer');
const mammoth = require('mammoth');
const pdfParse = require('pdf-parse');
const path = require('path');
const axios = require('axios'); // still needed to call your local AI server

const app = express();
app.use(cors({ origin: true }));
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

app.post('/extract', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });

    const file = req.file;
    const ext = path.extname(file.originalname).toLowerCase();
    let text = '';

    if (ext === '.txt') {
      text = file.buffer.toString('utf8');
    } else if (ext === '.docx') {
      const result = await mammoth.extractRawText({ buffer: file.buffer });
      text = result.value || '';
    } else if (ext === '.pdf') {
      const result = await pdfParse(file.buffer);
      text = result.text || '';
    } else {
      return res.status(415).json({ error: `Unsupported file type: ${ext}` });
    }

    const cleaned = (text || '').replace(/\s+/g, ' ').trim();
    if (!cleaned) return res.json({ error: 'No text found in file.' });

    // --- Send to your local GPT-2 Flask server ---
    const prompt = `
You are a flashcard generator.
Analyze the following text and create subjects.
For each subject, create multiple flashcards with a "question" and "answer".
Return JSON in this format:
{
  "subjects": [
    {
      "name": "Subject Name",
      "cards": [
        {"question": "Q1", "answer": "A1"},
        {"question": "Q2", "answer": "A2"}
      ]
    }
  ]
}
Text: """${cleaned}"""
`;

    const aiResp = await axios.post('http://localhost:5000/generate', { inputs: prompt }, { timeout: 60000 });
    
    let flashcards;
    try {
      const textOutput = aiResp.data?.generated_text || '';
      flashcards = JSON.parse(textOutput); // parse the JSON your GPT-2 returns
    } catch (e) {
      console.error('Failed to parse AI output:', e, aiResp.data);
      flashcards = { error: 'Failed to generate flashcards' };
    }

    res.json({ fileName: file.originalname, chars: cleaned.length, flashcards });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to extract text or generate flashcards', detail: String(err) });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
