# =====================================================
# SUPER AI ULTIMATE - ALL IN ONE FILE (FIXED VERSION)
# =====================================================
# Save as SuperAIOne.ps1 and run
# =====================================================
param([switch]$BuildExe=$false,[switch]$NoVoice=$false,[switch]$Update=$false)

# CONFIG
$SCRIPT:ROOT = $PSScriptRoot
if (-not $ROOT) { $SCRIPT:ROOT = Get-Location }
$PYTHON_APP = "$ROOT\super_ai_app.py"
$MEMORY_FILE = "$ROOT\memory.json"
$KNOWLEDGE_FOLDER = "$ROOT\knowledge"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                SUPER AI ULTIMATE v3.0                    ║" -ForegroundColor Yellow
Write-Host "║          Complete Offline AI - One File Setup           ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 1. CREATE PYTHON APP
Write-Host "[1/8] 📦 Creating AI system..." -ForegroundColor Green

$pythonCode = @'
# =====================================================
# SUPER AI ULTIMATE - COMPLETE SYSTEM
# =====================================================
import os, sys, json, re, subprocess, threading, time, tempfile, hashlib
import numpy as np
from datetime import datetime
from typing import List, Dict, Optional, Any
from dataclasses import dataclass, asdict

# Try to import optional packages
try: 
    from flask import Flask, request, jsonify, render_template_string
    FLASK_AVAILABLE = True
except: 
    FLASK_AVAILABLE = False
    print("Note: Flask not available, web interface disabled")

try: 
    from sentence_transformers import SentenceTransformer
    ST_AVAILABLE = True
except: 
    ST_AVAILABLE = False
    print("Note: Sentence transformers not available")

try: 
    from PyPDF2 import PdfReader
    PDF_AVAILABLE = True
except: 
    PDF_AVAILABLE = False

try: 
    import pandas as pd
    PANDAS_AVAILABLE = True
except: 
    PANDAS_AVAILABLE = False

try: 
    from docx import Document
    DOCX_AVAILABLE = True
except: 
    DOCX_AVAILABLE = False

try: 
    from PIL import Image
    PIL_AVAILABLE = True
except: 
    PIL_AVAILABLE = False

try: 
    import pytesseract
    TESSERACT_AVAILABLE = True
except: 
    TESSERACT_AVAILABLE = False

try: 
    import pyttsx3
    TTS_AVAILABLE = True
except: 
    TTS_AVAILABLE = False

try: 
    import speech_recognition as sr
    STT_AVAILABLE = True
except: 
    STT_AVAILABLE = False

try: 
    from selenium import webdriver
    SELENIUM_AVAILABLE = True
except: 
    SELENIUM_AVAILABLE = False

# =====================================================
# CONFIG
# =====================================================
ROOT = os.path.dirname(os.path.abspath(__file__))
MEMORY_FILE = os.path.join(ROOT, 'memory.json')
KNOWLEDGE_FOLDER = os.path.join(ROOT, 'knowledge')
MODELS_FOLDER = os.path.join(ROOT, 'models')

# Create folders
for folder in [KNOWLEDGE_FOLDER, MODELS_FOLDER, os.path.join(ROOT, 'temp')]:
    os.makedirs(folder, exist_ok=True)

# =====================================================
# DATA STRUCTURES
# =====================================================
@dataclass
class MemoryEntry:
    query: str
    answer: str
    timestamp: str
    topic: str
    confidence: float

@dataclass 
class KnowledgeDoc:
    filename: str
    content: str
    score: float = 0.0

# =====================================================
# SIMILARITY ENGINE
# =====================================================
class SimilarityEngine:
    @staticmethod
    def text_to_vector(text: str) -> Dict[str, int]:
        words = re.findall(r'\w+', text.lower())
        return {word: words.count(word) for word in set(words)}
    
    @staticmethod
    def cosine_similarity(vec1: Dict, vec2: Dict) -> float:
        common = set(vec1.keys()) & set(vec2.keys())
        dot = sum(vec1[w] * vec2[w] for w in common)
        norm1 = sum(v*v for v in vec1.values()) ** 0.5
        norm2 = sum(v*v for v in vec2.values()) ** 0.5
        if norm1 == 0 or norm2 == 0: return 0.0
        return dot / (norm1 * norm2)
    
    def calculate(self, query: str, text: str) -> float:
        return self.cosine_similarity(
            self.text_to_vector(query),
            self.text_to_vector(text[:5000])
        )

# =====================================================
# KNOWLEDGE INGESTION
# =====================================================
class KnowledgeBase:
    def __init__(self, folder: str):
        self.folder = folder
        self.documents: List[KnowledgeDoc] = []
        self.similarity = SimilarityEngine()
        self.load_all()
    
    def load_all(self):
        print("📚 Loading knowledge base...")
        if not os.path.exists(self.folder):
            print("  No knowledge folder found")
            return
        
        for filename in os.listdir(self.folder):
            path = os.path.join(self.folder, filename)
            try:
                content = self.read_file(path)
                if content and len(content.strip()) > 10:
                    self.documents.append(KnowledgeDoc(filename, content))
                    print(f"  ✓ {filename}")
            except Exception as e:
                print(f"  ✗ {filename}: {str(e)[:50]}")
        
        print(f"📊 Loaded {len(self.documents)} documents")
    
    def read_file(self, path: str) -> str:
        ext = os.path.splitext(path)[1].lower()
        
        # Text files
        if ext in ['.txt', '.md', '.json', '.csv', '.xml', '.html']:
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    return f.read()
            except:
                return ""
        
        # PDF files
        elif ext == '.pdf' and PDF_AVAILABLE:
            try:
                text = []
                reader = PdfReader(path)
                for page in reader.pages[:5]:
                    page_text = page.extract_text()
                    if page_text: text.append(page_text)
                return ' '.join(text)
            except:
                return ""
        
        # Word documents
        elif ext == '.docx' and DOCX_AVAILABLE:
            try:
                doc = Document(path)
                return ' '.join([para.text for para in doc.paragraphs[:50]])
            except:
                return ""
        
        # Excel files
        elif ext in ['.xlsx', '.xls'] and PANDAS_AVAILABLE:
            try:
                df = pd.read_excel(path, sheet_name=None, nrows=50)
                return ' '.join([df[sheet].astype(str).to_string() for sheet in df])
            except:
                return ""
        
        # Images (OCR)
        elif ext in ['.jpg', '.jpeg', '.png', '.bmp'] and PIL_AVAILABLE and TESSERACT_AVAILABLE:
            try:
                img = Image.open(path)
                return pytesseract.image_to_string(img)
            except:
                return ""
        
        return ""
    
    def search(self, query: str, limit: int = 3) -> List[KnowledgeDoc]:
        results = []
        for doc in self.documents:
            score = self.similarity.calculate(query, doc.content[:2000])
            if score > 0.1:
                results.append(KnowledgeDoc(doc.filename, doc.content[:500], score))
        
        results.sort(key=lambda x: x.score, reverse=True)
        return results[:limit]
    
    def get_context(self, query: str) -> str:
        results = self.search(query)
        if not results:
            return "No relevant documents found in knowledge base."
        
        context = "Relevant information from knowledge base:\n"
        for i, doc in enumerate(results, 1):
            context += f"\n[{i}] From '{doc.filename}' (relevance: {doc.score:.2f}):\n"
            context += doc.content + "\n"
        return context

# =====================================================
# MEMORY & CURRICULUM
# =====================================================
class MemoryManager:
    def __init__(self, memory_file: str):
        self.memory_file = memory_file
        self.memory = self.load()
        self.topics = {}
        self.analyze_topics()
    
    def load(self) -> List[MemoryEntry]:
        if os.path.exists(self.memory_file):
            try:
                with open(self.memory_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    return [MemoryEntry(**entry) for entry in data]
            except:
                pass
        return []
    
    def save(self):
        with open(self.memory_file, 'w', encoding='utf-8') as f:
            json.dump([asdict(m) for m in self.memory], f, indent=2, ensure_ascii=False)
    
    def analyze_topics(self):
        topic_keywords = {
            'ai': ['ai', 'artificial', 'intelligence', 'machine', 'learning', 'neural', 'model'],
            'code': ['code', 'program', 'python', 'javascript', 'java', 'function', 'algorithm'],
            'science': ['science', 'physics', 'chemistry', 'biology', 'research', 'experiment'],
            'math': ['math', 'calculate', 'equation', 'algebra', 'geometry', 'statistics'],
            'history': ['history', 'past', 'ancient', 'century', 'war', 'historical'],
            'tech': ['tech', 'computer', 'software', 'hardware', 'device', 'digital'],
            'business': ['business', 'company', 'market', 'product', 'sales', 'customer'],
            'health': ['health', 'medical', 'doctor', 'patient', 'treatment', 'medicine'],
            'art': ['art', 'paint', 'music', 'creative', 'design', 'artist', 'culture'],
            'sports': ['sports', 'game', 'team', 'player', 'win', 'score', 'champion']
        }
        
        for entry in self.memory[-50:]:
            text = (entry.query + ' ' + entry.answer).lower()
            for topic, keywords in topic_keywords.items():
                if any(keyword in text for keyword in keywords):
                    self.topics[topic] = self.topics.get(topic, 0) + 1
    
    def add(self, query: str, answer: str, confidence: float = 0.5):
        # Detect topic
        text = query.lower()
        detected_topic = "general"
        for topic in ['ai', 'code', 'science', 'math', 'history', 'tech', 'business', 'health', 'art', 'sports']:
            if topic in text:
                detected_topic = topic
                break
        
        entry = MemoryEntry(
            query=query,
            answer=answer,
            timestamp=datetime.now().isoformat(),
            topic=detected_topic,
            confidence=confidence
        )
        self.memory.append(entry)
        self.save()
        self.analyze_topics()
    
    def get_next_topic(self) -> str:
        if not self.topics:
            return "artificial intelligence"
        
        if self.topics:
            min_count = min(self.topics.values())
            candidates = [t for t, c in self.topics.items() if c == min_count]
            return candidates[0] if candidates else "technology"
        return "general knowledge"

# =====================================================
# REASONING ENGINE
# =====================================================
class ReasoningEngine:
    def __init__(self):
        self.templates = {
            'what': [
                "Based on available information, {query} refers to: {context}",
                "What I understand about {query} is: {context}",
                "According to the knowledge base: {context}"
            ],
            'how': [
                "Here's how {query}: {context}",
                "The process involves: {context}",
                "To accomplish this: {context}"
            ],
            'why': [
                "The reason for {query} is: {context}",
                "This occurs because: {context}",
                "Several factors explain this: {context}"
            ],
            'who': [
                "Regarding {query}: {context}",
                "The person/entity mentioned: {context}",
                "From available information: {context}"
            ],
            'when': [
                "The timing for {query} is: {context}",
                "This occurs around: {context}",
                "Based on records: {context}"
            ],
            'where': [
                "The location for {query} is: {context}",
                "This is situated at: {context}",
                "Geographically: {context}"
            ],
            'general': [
                "Interesting question about {query}. {context}",
                "Regarding your question: {context}",
                "I found this information: {context}"
            ]
        }
    
    def detect_question_type(self, query: str) -> str:
        query_lower = query.lower()
        for qtype in ['what', 'how', 'why', 'who', 'when', 'where']:
            if query_lower.startswith(qtype):
                return qtype
        return 'general'
    
    def generate_answer(self, query: str, context: str) -> str:
        qtype = self.detect_question_type(query)
        templates = self.templates.get(qtype, self.templates['general'])
        
        import random
        template = random.choice(templates)
        
        # Format the answer
        answer = template.format(query=query, context=context[:300])
        
        # Add confidence indicator
        confidence = min(len(context) / 100, 0.9)
        if confidence > 0.7:
            answer += " (High confidence)"
        elif confidence > 0.4:
            answer += " (Medium confidence)"
        else:
            answer += " (Limited information available)"
        
        return answer

# =====================================================
# VOICE INTERFACE
# =====================================================
class VoiceInterface:
    def __init__(self, enabled: bool = True):
        self.enabled = enabled and TTS_AVAILABLE and STT_AVAILABLE
        self.tts = None
        self.stt = None
        
        if self.enabled:
            try:
                self.tts = pyttsx3.init()
                self.tts.setProperty('rate', 150)
                self.stt = sr.Recognizer()
            except:
                self.enabled = False
    
    def speak(self, text: str):
        if not self.enabled or not self.tts:
            print(f"[Voice would say]: {text[:100]}...")
            return
        
        def speak_thread():
            try:
                self.tts.say(text[:200])
                self.tts.runAndWait()
            except:
                pass
        
        threading.Thread(target=speak_thread, daemon=True).start()
    
    def listen(self) -> Optional[str]:
        if not self.enabled or not self.stt:
            return None
        
        try:
            with sr.Microphone() as source:
                print("🎤 Listening... (speak now)")
                self.stt.adjust_for_ambient_noise(source, duration=0.5)
                audio = self.stt.listen(source, timeout=5, phrase_time_limit=10)
                return self.stt.recognize_google(audio)
        except:
            return None

# =====================================================
# WEB INTEGRATION
# =====================================================
class WebAssistant:
    def __init__(self):
        self.available = SELENIUM_AVAILABLE
        self.driver = None
    
    def search_web(self, query: str) -> str:
        if not self.available:
            return "Web search unavailable (Selenium not installed)"
        
        try:
            from selenium.webdriver.common.by import By
            from selenium.webdriver.support.ui import WebDriverWait
            from selenium.webdriver.support import expected_conditions as EC
            
            options = webdriver.ChromeOptions()
            options.add_argument('--headless')
            options.add_argument('--no-sandbox')
            options.add_argument('--disable-dev-shm-usage')
            
            self.driver = webdriver.Chrome(options=options)
            self.driver.get(f"https://www.google.com/search?q={query.replace(' ', '+')}")
            
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "div.g"))
            )
            
            results = self.driver.find_elements(By.CSS_SELECTOR, "div.g")[:3]
            content = []
            for result in results:
                try:
                    text = result.text
                    if len(text) > 50:
                        content.append(text[:200])
                except:
                    continue
            
            self.driver.quit()
            return "Web search results: " + " | ".join(content) if content else "No web results found"
        
        except Exception as e:
            return f"Web search error: {str(e)}"

# =====================================================
# MAIN AI AGENT
# =====================================================
class SuperAIAgent:
    def __init__(self, voice_enabled: bool = True):
        print("🚀 Initializing Super AI...")
        
        self.knowledge = KnowledgeBase(KNOWLEDGE_FOLDER)
        self.memory = MemoryManager(MEMORY_FILE)
        self.reasoning = ReasoningEngine()
        self.voice = VoiceInterface(voice_enabled)
        self.web = WebAssistant()
        
        print("✅ Super AI Ready!")
        print(f"   Knowledge: {len(self.knowledge.documents)} documents")
        print(f"   Memory: {len(self.memory.memory)} conversations")
        print(f"   Voice: {'Enabled' if self.voice.enabled else 'Disabled'}")
        print(f"   Next topic suggestion: {self.memory.get_next_topic()}")
    
    def process(self, query: str, use_web: bool = False) -> Dict[str, Any]:
        print(f"🤖 Processing: {query}")
        
        # Get context from knowledge
        context = self.knowledge.get_context(query)
        
        # Optional web search
        if use_web and ('search' in query.lower() or 'http' in query.lower()):
            web_info = self.web.search_web(query)
            context += "\n\n" + web_info
        
        # Generate answer
        answer = self.reasoning.generate_answer(query, context)
        
        # Calculate confidence
        confidence = min(len(context) / 500, 0.95)
        
        # Store in memory
        self.memory.add(query, answer, confidence)
        
        # Speak if voice enabled
        self.voice.speak(answer[:150])
        
        return {
            'answer': answer,
            'confidence': f"{confidence:.0%}",
            'sources': len(self.knowledge.search(query)),
            'next_topic': self.memory.get_next_topic(),
            'timestamp': datetime.now().strftime("%H:%M:%S")
        }

# =====================================================
# WEB INTERFACE
# =====================================================
if FLASK_AVAILABLE:
    app = Flask(__name__)
    ai_agent = None
    
    HTML = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Super AI</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
            body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
            .container { max-width: 1000px; margin: 0 auto; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
            .header { background: linear-gradient(90deg, #4f46e5, #7c3aed); color: white; padding: 20px; text-align: center; }
            .header h1 { font-size: 2em; margin-bottom: 5px; }
            .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; padding: 15px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; }
            .stat { text-align: center; }
            .stat .value { font-size: 1.5em; font-weight: bold; color: #4f46e5; }
            .stat .label { font-size: 0.8em; color: #64748b; }
            .main { display: flex; min-height: 500px; }
            .sidebar { width: 250px; background: #f1f5f9; padding: 20px; border-right: 1px solid #e2e8f0; }
            .chat { flex: 1; padding: 20px; display: flex; flex-direction: column; }
            .messages { flex: 1; overflow-y: auto; margin-bottom: 20px; padding: 15px; background: #f8fafc; border-radius: 10px; }
            .message { margin-bottom: 10px; padding: 12px; border-radius: 10px; max-width: 80%; }
            .user { background: #4f46e5; color: white; margin-left: auto; }
            .ai { background: #e2e8f0; color: #1e293b; }
            .input-area { display: flex; gap: 10px; }
            input { flex: 1; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; font-size: 1em; }
            button { background: #4f46e5; color: white; border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer; }
            button:hover { background: #4338ca; }
            .voice-btn { background: #10b981; }
            .topic { background: #dbeafe; color: #1e40af; padding: 5px 10px; border-radius: 15px; margin: 3px; display: inline-block; cursor: pointer; }
            .topic:hover { background: #bfdbfe; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🤖 Super AI Ultimate</h1>
                <p>Offline AI Assistant</p>
            </div>
            
            <div class="stats">
                <div class="stat"><div class="value" id="mem-count">0</div><div class="label">Conversations</div></div>
                <div class="stat"><div class="value" id="doc-count">0</div><div class="label">Documents</div></div>
                <div class="stat"><div class="value" id="conf">0%</div><div class="label">Confidence</div></div>
                <div class="stat"><div class="value" id="topic">General</div><div class="label">Current Topic</div></div>
            </div>
            
            <div class="main">
                <div class="sidebar">
                    <h3>📚 Knowledge</h3>
                    <div id="docs"></div>
                    
                    <h3 style="margin-top: 20px;">🎯 Topics</h3>
                    <div id="topics"></div>
                    
                    <button onclick="voice()" class="voice-btn" style="width: 100%; margin-top: 20px;">🎤 Voice Input</button>
                    <button onclick="suggest()" style="width: 100%; margin-top: 10px;">💡 Suggest Topic</button>
                </div>
                
                <div class="chat">
                    <div class="messages" id="messages">
                        <div class="message ai">Hello! I'm your Super AI assistant. I learn from documents in the knowledge folder and remember our conversations. Ask me anything!</div>
                    </div>
                    
                    <div class="input-area">
                        <input type="text" id="query" placeholder="Ask me anything..." onkeypress="if(event.key=='Enter') send()">
                        <button onclick="send()">Send</button>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            function updateStats() {
                fetch('/stats').then(r => r.json()).then(data => {
                    document.getElementById('mem-count').textContent = data.memory;
                    document.getElementById('doc-count').textContent = data.documents;
                    document.getElementById('conf').textContent = data.confidence;
                    document.getElementById('topic').textContent = data.topic;
                    
                    let docs = document.getElementById('docs');
                    docs.innerHTML = data.doc_list.slice(0, 5).map(d => 
                        '<div style="margin: 5px 0; padding: 5px; background: white; border-radius: 5px; font-size: 0.9em;">📄 ' + d + '</div>'
                    ).join('');
                    
                    let topics = document.getElementById('topics');
                    topics.innerHTML = data.topics.map(t => 
                        '<span class="topic" onclick="setTopic(\'' + t + '\')">' + t + '</span>'
                    ).join('');
                });
            }
            
            function send() {
                let query = document.getElementById('query').value;
                if (!query) return;
                
                addMessage(query, 'user');
                document.getElementById('query').value = '';
                
                fetch('/chat', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({q: query})
                })
                .then(r => r.json())
                .then(data => {
                    addMessage(data.answer, 'ai');
                    updateStats();
                });
            }
            
            function addMessage(text, sender) {
                let msg = document.getElementById('messages');
                let div = document.createElement('div');
                div.className = 'message ' + sender;
                div.textContent = text;
                msg.appendChild(div);
                msg.scrollTop = msg.scrollHeight;
            }
            
            function voice() {
                fetch('/voice').then(r => r.json()).then(data => {
                    if (data.text) {
                        document.getElementById('query').value = data.text;
                    } else {
                        alert('Could not understand voice input');
                    }
                });
            }
            
            function suggest() {
                fetch('/suggest').then(r => r.json()).then(data => {
                    document.getElementById('query').value = 'Tell me about ' + data.topic;
                });
            }
            
            function setTopic(topic) {
                document.getElementById('query').value = 'Tell me about ' + topic;
            }
            
            // Initialize
            updateStats();
            setInterval(updateStats, 5000);
        </script>
    </body>
    </html>
    '''
    
    @app.route('/')
    def home():
        return render_template_string(HTML)
    
    @app.route('/chat', methods=['POST'])
    def chat():
        if not ai_agent:
            return jsonify({'error': 'AI not ready'})
        data = request.json
        result = ai_agent.process(data.get('q', ''))
        return jsonify(result)
    
    @app.route('/voice')
    def voice():
        if not ai_agent:
            return jsonify({'text': ''})
        text = ai_agent.voice.listen()
        return jsonify({'text': text or ''})
    
    @app.route('/suggest')
    def suggest():
        if not ai_agent:
            return jsonify({'topic': 'AI'})
        return jsonify({'topic': ai_agent.memory.get_next_topic()})
    
    @app.route('/stats')
    def stats():
        if not ai_agent:
            return jsonify({
                'memory': 0,
                'documents': 0,
                'confidence': '0%',
                'topic': 'General',
                'doc_list': [],
                'topics': []
            })
        
        docs = [d.filename for d in ai_agent.knowledge.documents[:10]]
        topics = list(ai_agent.memory.topics.keys())[:6]
        
        return jsonify({
            'memory': len(ai_agent.memory.memory),
            'documents': len(ai_agent.knowledge.documents),
            'confidence': f"{ai_agent.memory.memory[-1].confidence:.0%}" if ai_agent.memory.memory else '0%',
            'topic': ai_agent.memory.get_next_topic(),
            'doc_list': docs,
            'topics': topics
        })
    
    def run_server(port=8000):
        import waitress
        print(f"🌐 Web interface: http://localhost:{port}")
        print("💬 Chat in your browser!")
        waitress.serve(app, host='0.0.0.0', port=port)

# =====================================================
# MAIN EXECUTION
# =====================================================
def main(voice_enabled: bool = True, port: int = 8000):
    global ai_agent
    
    # Initialize AI
    ai_agent = SuperAIAgent(voice_enabled=voice_enabled)
    
    if FLASK_AVAILABLE:
        print(f"🌐 Web interface available at: http://localhost:{port}")
        print("📁 Add documents to 'knowledge' folder")
        print("💬 Chat in browser or use Python API")
        print("\n⚡ Press Ctrl+C to stop\n")
        
        # Run Flask
        import waitress
        waitress.serve(app, host='0.0.0.0', port=port)
    else:
        print("⚠ Flask not available. Running in console mode...")
        print("💬 Type 'quit' to exit, 'web' to search web\n")
        
        while True:
            query = input("You: ")
            if query.lower() in ['quit', 'exit', 'bye']:
                break
            elif query.lower() == 'web':
                query = input("Search web for: ")
                result = ai_agent.process(query, use_web=True)
            else:
                result = ai_agent.process(query)
            
            print(f"AI: {result['answer']}")
            print(f"   Confidence: {result['confidence']}, Next topic: {result['next_topic']}\n")

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--no-voice', action='store_true')
    parser.add_argument('--port', type=int, default=8000)
    args = parser.parse_args()
    
    main(voice_enabled=not args.no_voice, port=args.port)
'@

# Save Python app
$pythonCode | Set-Content -Path $PYTHON_APP -Encoding UTF8
Write-Host "  ✓ Created Python application" -ForegroundColor Green

# 2. CREATE EXAMPLE KNOWLEDGE FILES
Write-Host "[2/8] 📚 Creating example knowledge base..." -ForegroundColor Green
if (-not (Test-Path $KNOWLEDGE_FOLDER)) { 
    New-Item -ItemType Directory -Path $KNOWLEDGE_FOLDER | Out-Null 
    Write-Host "  ✓ Created knowledge folder" -ForegroundColor Green
}

# AI Knowledge File
$aiContent = @"
# Artificial Intelligence

Artificial Intelligence (AI) refers to the simulation of human intelligence in machines. 
Key branches include:

1. Machine Learning: Algorithms that learn from data
2. Natural Language Processing: Understanding human language
3. Computer Vision: Interpreting visual information
4. Robotics: Intelligent physical systems

Applications:
- Virtual assistants (Siri, Alexa)
- Recommendation systems (Netflix, Amazon)
- Autonomous vehicles
- Medical diagnosis
- Fraud detection

History:
1956: Dartmouth Conference coins term "AI"
1997: IBM Deep Blue defeats chess champion
2011: IBM Watson wins Jeopardy!
2016: AlphaGo beats world Go champion
2020s: GPT models revolutionize language AI

Current Trends:
- Large Language Models (GPT, Llama, Claude)
- Multimodal AI (text, image, audio combined)
- Edge AI (on-device processing)
- AI ethics and safety research
"@
$aiContent | Set-Content -Path "$KNOWLEDGE_FOLDER\ai_knowledge.txt" -Encoding UTF8
Write-Host "  ✓ Created ai_knowledge.txt" -ForegroundColor Green

# Programming Knowledge File
$progContent = @"
# Programming Fundamentals

## Python
Python is a high-level, interpreted programming language known for readability.

Key Features:
- Simple syntax
- Dynamic typing
- Automatic memory management
- Extensive standard library
- Supports multiple paradigms (OOP, functional, procedural)

Example Code:
def factorial(n):
    if n == 0:
        return 1
    return n * factorial(n-1)

## Data Structures
1. Arrays/Lists: Sequential collections
2. Stacks: LIFO (Last In First Out)
3. Queues: FIFO (First In First Out)
4. Linked Lists: Node-based sequences
5. Trees: Hierarchical structures
6. Hash Tables: Key-value pairs for fast lookup

## Algorithms
- Sorting: QuickSort, MergeSort, BubbleSort
- Searching: Binary Search, Linear Search
- Graph Algorithms: Dijkstra, BFS, DFS
- Dynamic Programming: Memoization, Tabulation

## Web Development
- Frontend: HTML, CSS, JavaScript
- Backend: Node.js, Python (Django/Flask), Java, C#
- Databases: SQL (MySQL, PostgreSQL), NoSQL (MongoDB)
- APIs: REST, GraphQL

## Best Practices
- Write readable code with comments
- Use version control (Git)
- Write tests
- Follow coding standards
- Document your code
"@
$progContent | Set-Content -Path "$KNOWLEDGE_FOLDER\programming.txt" -Encoding UTF8
Write-Host "  ✓ Created programming.txt" -ForegroundColor Green

# 3. CHECK PYTHON
Write-Host "[3/8] 🐍 Checking Python..." -ForegroundColor Green
if ($null -eq (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Python not found. Attempting to find it..." -ForegroundColor Yellow
    
    # Try python3
    if ($null -ne (Get-Command python3 -ErrorAction SilentlyContinue)) {
        Write-Host "  Found python3" -ForegroundColor Green
    } else {
        Write-Host "  Please install Python 3.8+ from python.org" -ForegroundColor Red
        Write-Host "  Then re-run this script" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "  ✓ Python found" -ForegroundColor Green
}

# 4. INSTALL PACKAGES
Write-Host "[4/8] 📦 Installing Python packages..." -ForegroundColor Green

$packages = @(
    "flask",
    "numpy",
    "waitress",
    "PyPDF2",
    "pandas",
    "python-docx",
    "Pillow",
    "pytesseract",
    "pyttsx3",
    "SpeechRecognition",
    "selenium"
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..." -NoNewline
    $result = pip install $pkg --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗" -ForegroundColor Yellow
    }
}

# 5. CREATE LAUNCHER FILES
Write-Host "[5/8] 🚀 Creating launchers..." -ForegroundColor Green

# Windows batch file
$batchContent = @'
@echo off
chcp 65001 >nul
echo.
echo ========================================
echo     SUPER AI ULTIMATE - Starting
echo ========================================
echo.
echo Opening browser to: http://localhost:8000
echo.
echo Press Ctrl+C in this window to stop
echo.
timeout /t 3 /nobreak >nul

REM Check for Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Python not found!
    echo Please install Python 3.8+ from python.org
    pause
    exit /b 1
)

REM Start Python server
python "%~dp0super_ai_app.py" --no-voice

if errorlevel 1 (
    echo.
    echo Trying without --no-voice option...
    python "%~dp0super_ai_app.py"
)
'@
$batchContent | Set-Content -Path "$ROOT\start_ai.bat" -Encoding ASCII
Write-Host "  ✓ Created start_ai.bat" -ForegroundColor Green

# PowerShell launcher
$psLauncher = @'
Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          Starting Super AI Ultimate           ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$port = 8000
$url = "http://localhost:$port"

Write-Host "🌐 Web Interface: $url" -ForegroundColor Green
Write-Host "📁 Knowledge Folder: $PSScriptRoot\knowledge" -ForegroundColor Cyan
Write-Host "💾 Memory File: $PSScriptRoot\memory.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Loading AI system..." -ForegroundColor Yellow

$noVoice = $args -contains "--no-voice"

if ($noVoice) {
    Start-Process python -ArgumentList "`"$PSScriptRoot\super_ai_app.py`"", "--no-voice" -NoNewWindow
} else {
    Start-Process python -ArgumentList "`"$PSScriptRoot\super_ai_app.py`"" -NoNewWindow
}

Start-Sleep 3

try {
    Start-Process $url
    Write-Host "✅ Browser opened!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not open browser automatically" -ForegroundColor Yellow
    Write-Host "   Please open: $url" -ForegroundColor White
}

Write-Host ""
Write-Host "🤖 AI is now running!" -ForegroundColor Green
Write-Host "   Press Ctrl+C in the Python window to stop" -ForegroundColor Gray
Write-Host ""
'@
$psLauncher | Set-Content -Path "$ROOT\Start-AI.ps1" -Encoding UTF8
Write-Host "  ✓ Created Start-AI.ps1" -ForegroundColor Green

# 6. CREATE README
Write-Host "[6/8] 📖 Creating documentation..." -ForegroundColor Green

$readmeContent = @"
# SUPER AI ULTIMATE - QUICK GUIDE

## 🚀 QUICK START
1. Double-click `start_ai.bat` or run `.\Start-AI.ps1`
2. Browser opens at http://localhost:8000
3. Start chatting!

## 📁 ADD YOUR KNOWLEDGE
Place files in the `knowledge` folder:
- Text files (.txt, .md)
- PDF documents (.pdf)
- Word documents (.docx)
- Excel files (.xlsx, .xls)
- Images for OCR (.jpg, .png)
- JSON files (.json)

The AI will automatically read and learn from them.

## 🎤 VOICE FEATURES
- Click 🎤 button in web interface for voice input
- AI speaks responses automatically
- Requires microphone and speakers

## 🔍 WEB SEARCH
Include "search" in your question or a URL to enable web search:
- "search for latest AI news"
- "what is http://example.com about"

## 📊 MEMORY SYSTEM
- AI remembers all conversations
- Learns your interests over time
- Suggests new topics to explore
- Exports memory to JSON

## ⚙️ COMMAND LINE OPTIONS
.\Start-AI.ps1 [--no-voice]
start_ai.bat

Or run directly:
python super_ai_app.py [--no-voice] [--port 8000]

## 🛠 TROUBLESHOOTING

### Python not found:
Install Python 3.8+ from python.org

### Package installation fails:
Run PowerShell as Administrator
Or install manually: pip install flask numpy waitress

### Voice not working:
Check microphone permissions
Install: pip install pyttsx3 SpeechRecognition

### Web search not working:
Install Chrome browser
Run: pip install selenium

Enjoy your personal AI assistant!
"@
$readmeContent | Set-Content -Path "$ROOT\README.txt" -Encoding UTF8
Write-Host "  ✓ Created README.txt" -ForegroundColor Green

# 7. CREATE INITIAL MEMORY
Write-Host "[7/8] 💾 Creating memory system..." -ForegroundColor Green

$memoryContent = @"
[
  {
    "query": "What can you do?",
    "answer": "I'm Super AI Ultimate! I can learn from documents, remember our conversations, answer questions, use voice input/output, search the web, and suggest new topics to explore. Try asking me about AI, programming, science, or anything in your knowledge folder!",
    "timestamp": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')",
    "topic": "general",
    "confidence": 0.9
  }
]
"@
$memoryContent | Set-Content -Path $MEMORY_FILE -Encoding UTF8
Write-Host "  ✓ Created memory.json" -ForegroundColor Green

# 8. FINAL MESSAGE
Write-Host "[8/8] 🎉 Setup complete!" -ForegroundColor Green

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                     SETUP COMPLETE!                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Everything is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 FILES CREATED:" -ForegroundColor Yellow
Get-ChildItem $ROOT -File | ForEach-Object {
    Write-Host "   • $($_.Name)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "🚀 TO START:" -ForegroundColor Yellow
Write-Host "   1. Double-click 'start_ai.bat'" -ForegroundColor White
Write-Host "   2. OR run '.\Start-AI.ps1' in PowerShell" -ForegroundColor White
Write-Host "   3. Browser opens automatically" -ForegroundColor White
Write-Host ""
Write-Host "💡 TIPS:" -ForegroundColor Cyan
Write-Host "   • Add your documents to the 'knowledge' folder" -ForegroundColor Gray
Write-Host "   • AI learns and improves over time" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 Web Interface: http://localhost:8000" -ForegroundColor Green
Write-Host ""

# Ask to launch
$launch = Read-Host "Launch AI now? (Y/N)"
if ($launch -eq 'Y' -or $launch -eq 'y') {
    Write-Host "Starting AI..." -ForegroundColor Yellow
    
    $args = @()
    if ($NoVoice) { $args += "--no-voice" }
    
    Start-Process python -ArgumentList @("`"$PYTHON_APP`"", $args) -NoNewWindow
    
    Start-Sleep 3
    
    try {
        Start-Process "http://localhost:8000"
        Write-Host "✅ Browser opened!" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Open manually: http://localhost:8000" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🤖 AI is running! Check the Python window for status." -ForegroundColor Green
    Write-Host "   Press Ctrl+C in the Python window to stop." -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "📋 Run anytime:" -ForegroundColor Yellow
    Write-Host "   Double-click 'start_ai.bat' or run '.\Start-AI.ps1'" -ForegroundColor White
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "          Super AI Ultimate is ready to assist you!          " -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan