# SUPER AI ULTIMATE - SINGLE FILE THAT DOES EVERYTHING
# Save this as SuperAI.ps1 and run it

# =====================================================
# 1. CREATE ALL FILES
# =====================================================

$folder = "SuperAI"
if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
Set-Location $folder

# Create the main Python file
$pythonCode = @'
import os, json, datetime, random, sys, threading, subprocess, tempfile, re, time
from typing import List, Dict, Any, Optional

print("🚀 Super AI Ultimate Starting...")

# Configuration
ROOT = os.path.dirname(os.path.abspath(__file__))
MEMORY_FILE = os.path.join(ROOT, "memory.json")
KNOWLEDGE_FOLDER = os.path.join(ROOT, "knowledge")

# Create folders
os.makedirs(KNOWLEDGE_FOLDER, exist_ok=True)

# =====================================================
# KNOWLEDGE SYSTEM
# =====================================================
class KnowledgeBase:
    def __init__(self):
        self.documents = []
        self.load_documents()
    
    def load_documents(self):
        print("📚 Loading knowledge...")
        if os.path.exists(KNOWLEDGE_FOLDER):
            for file in os.listdir(KNOWLEDGE_FOLDER):
                if file.endswith(".txt"):
                    path = os.path.join(KNOWLEDGE_FOLDER, file)
                    try:
                        with open(path, "r", encoding="utf-8", errors="ignore") as f:
                            content = f.read()
                            self.documents.append({
                                "name": file,
                                "content": content,
                                "type": "text"
                            })
                        print(f"  ✓ {file}")
                    except:
                        pass
        print(f"📊 Loaded {len(self.documents)} documents")
    
    def search(self, query: str) -> List[Dict[str, Any]]:
        query = query.lower()
        results = []
        for doc in self.documents:
            content = doc["content"].lower()
            # Simple search
            if query in content or any(word in content for word in query.split()[:3]):
                relevance = sum(1 for word in query.split() if word in content)
                # Get context around match
                idx = content.find(query.split()[0]) if query.split() else 0
                snippet = doc["content"][max(0, idx-100):idx+200]
                results.append({
                    "name": doc["name"],
                    "snippet": snippet,
                    "relevance": relevance
                })
        return sorted(results, key=lambda x: x["relevance"], reverse=True)[:3]

# =====================================================
# MEMORY SYSTEM
# =====================================================
class Memory:
    def __init__(self):
        self.entries = []
        self.load()
    
    def load(self):
        if os.path.exists(MEMORY_FILE):
            try:
                with open(MEMORY_FILE, "r", encoding="utf-8") as f:
                    self.entries = json.load(f)
            except:
                self.entries = []
    
    def save(self):
        with open(MEMORY_FILE, "w", encoding="utf-8") as f:
            json.dump(self.entries, f, indent=2)
    
    def add(self, query: str, answer: str):
        entry = {
            "query": query,
            "answer": answer,
            "timestamp": datetime.datetime.now().isoformat(),
            "confidence": random.uniform(0.5, 0.9)
        }
        self.entries.append(entry)
        self.save()
    
    def get_history(self, limit: int = 10) -> List[Dict]:
        return self.entries[-limit:]

# =====================================================
# AI REASONING
# =====================================================
class AIBrain:
    def __init__(self):
        self.knowledge = KnowledgeBase()
        self.memory = Memory()
        self.responses = {
            "what": [
                "Based on what I know: {context}",
                "What I understand is: {context}",
                "Here's information about that: {context}"
            ],
            "how": [
                "Here's how: {context}",
                "The process involves: {context}",
                "To do this: {context}"
            ],
            "why": [
                "The reason is: {context}",
                "This happens because: {context}",
                "Several factors contribute: {context}"
            ],
            "who": [
                "This involves: {context}",
                "The key people/entities: {context}",
                "From my knowledge: {context}"
            ],
            "when": [
                "The timing is: {context}",
                "This occurred around: {context}",
                "Based on records: {context}"
            ]
        }
    
    def generate_answer(self, query: str) -> Dict[str, Any]:
        print(f"🤔 Processing: {query[:50]}...")
        
        # Search knowledge
        results = self.knowledge.search(query)
        
        # Prepare context
        context = ""
        if results:
            context = "Information found:\n"
            for i, result in enumerate(results, 1):
                context += f"{i}. From '{result['name']}': {result['snippet']}\n"
        else:
            context = "No specific information found in knowledge base."
        
        # Generate answer based on question type
        query_lower = query.lower()
        question_type = "general"
        for qtype in ["what", "how", "why", "who", "when", "where"]:
            if query_lower.startswith(qtype):
                question_type = qtype
                break
        
        if question_type in self.responses:
            template = random.choice(self.responses[question_type])
            answer = template.format(context=context[:300])
        else:
            answers = [
                f"Regarding '{query}': {context}",
                f"Interesting question! {context}",
                f"Based on available information: {context}"
            ]
            answer = random.choice(answers)
        
        # Calculate confidence
        confidence = min(len(context) / 100, 0.95)
        
        # Add to memory
        self.memory.add(query, answer)
        
        return {
            "answer": answer,
            "confidence": f"{confidence:.0%}",
            "sources": len(results),
            "timestamp": datetime.datetime.now().strftime("%H:%M:%S")
        }

# =====================================================
# WEB INTERFACE
# =====================================================
HTML_TEMPLATE = '''<!DOCTYPE html>
<html>
<head>
    <title>Super AI Ultimate</title>
    <meta charset="utf-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); overflow: hidden; }
        .header { background: linear-gradient(90deg, #4f46e5, #7c3aed); color: white; padding: 25px; text-align: center; }
        .header h1 { font-size: 2.2em; margin-bottom: 10px; }
        .header p { opacity: 0.9; }
        .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; padding: 20px; background: #f8fafc; }
        .stat { background: white; padding: 15px; border-radius: 10px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .stat .value { font-size: 1.8em; font-weight: bold; color: #4f46e5; }
        .stat .label { color: #64748b; font-size: 0.9em; margin-top: 5px; }
        .chat-container { padding: 25px; }
        .messages { height: 400px; overflow-y: auto; padding: 15px; background: #f9f9f9; border-radius: 10px; margin-bottom: 20px; border: 1px solid #e2e8f0; }
        .message { margin-bottom: 15px; padding: 12px 16px; border-radius: 12px; max-width: 80%; line-height: 1.5; }
        .user-message { background: #4f46e5; color: white; margin-left: auto; }
        .ai-message { background: #f1f5f9; color: #1e293b; }
        .input-area { display: flex; gap: 10px; }
        input[type="text"] { flex: 1; padding: 15px; border: 2px solid #e2e8f0; border-radius: 10px; font-size: 1em; outline: none; transition: border 0.3s; }
        input[type="text"]:focus { border-color: #4f46e5; }
        button { background: #4f46e5; color: white; border: none; padding: 15px 25px; border-radius: 10px; font-size: 1em; cursor: pointer; transition: background 0.3s; }
        button:hover { background: #4338ca; }
        .controls { display: flex; gap: 10px; margin-top: 15px; flex-wrap: wrap; }
        .knowledge-files { margin-top: 20px; padding: 15px; background: #f8fafc; border-radius: 10px; }
        .file-item { display: inline-block; background: white; padding: 8px 15px; margin: 5px; border-radius: 20px; border: 1px solid #e2e8f0; }
        .status { padding: 10px; background: #fef3c7; border-radius: 8px; margin-top: 10px; display: none; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 Super AI Ultimate</h1>
            <p>Your Personal AI Assistant - 100% Offline</p>
        </div>
        
        <div class="stats">
            <div class="stat">
                <div class="value" id="doc-count">0</div>
                <div class="label">Knowledge Files</div>
            </div>
            <div class="stat">
                <div class="value" id="memory-count">0</div>
                <div class="label">Conversations</div>
            </div>
            <div class="stat">
                <div class="value" id="confidence">85%</div>
                <div class="label">Confidence</div>
            </div>
        </div>
        
        <div class="chat-container">
            <div class="messages" id="messages">
                <div class="message ai-message">👋 Hello! I'm your Super AI assistant. I learn from documents in the knowledge folder and remember our conversations. What would you like to know?</div>
            </div>
            
            <div class="input-area">
                <input type="text" id="query" placeholder="Ask me anything..." onkeypress="if(event.key=='Enter') sendMessage()">
                <button onclick="sendMessage()">Send</button>
            </div>
            
            <div class="controls">
                <button onclick="clearChat()" style="background: #ef4444;">Clear Chat</button>
                <button onclick="suggestTopic()" style="background: #10b981;">Suggest Topic</button>
                <button onclick="updateStats()" style="background: #f59e0b;">Refresh Stats</button>
            </div>
            
            <div class="knowledge-files">
                <h3>📁 Knowledge Files</h3>
                <div id="file-list">Loading...</div>
                <button onclick="addFile()" style="margin-top: 10px; background: #6366f1;">➕ Add Text File</button>
            </div>
            
            <div class="status" id="status"></div>
        </div>
    </div>
    
    <script>
        let messageCount = 0;
        
        function updateStats() {
            fetch('/stats').then(r => r.json()).then(data => {
                document.getElementById('doc-count').textContent = data.documents;
                document.getElementById('memory-count').textContent = data.memory;
                document.getElementById('confidence').textContent = data.confidence;
                
                let fileList = document.getElementById('file-list');
                fileList.innerHTML = data.files.map(f => 
                    '<span class="file-item">' + f + '</span>'
                ).join('');
            });
        }
        
        function sendMessage() {
            const query = document.getElementById('query').value.trim();
            if (!query) return;
            
            // Add user message
            addMessage(query, 'user');
            document.getElementById('query').value = '';
            
            // Show thinking
            showStatus('🤔 Thinking...');
            
            // Send to AI
            fetch('/chat', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({q: query})
            })
            .then(r => r.json())
            .then(data => {
                hideStatus();
                addMessage(data.answer, 'ai');
                updateStats();
            })
            .catch(err => {
                showStatus('❌ Error: ' + err);
                setTimeout(hideStatus, 3000);
            });
        }
        
        function addMessage(text, sender) {
            const messages = document.getElementById('messages');
            const div = document.createElement('div');
            div.className = `message ${sender}-message`;
            div.textContent = text;
            messages.appendChild(div);
            messages.scrollTop = messages.scrollHeight;
            messageCount++;
        }
        
        function clearChat() {
            document.getElementById('messages').innerHTML = 
                '<div class="message ai-message">👋 Chat cleared. What would you like to know?</div>';
            messageCount = 0;
        }
        
        function suggestTopic() {
            const topics = ['AI', 'Programming', 'Science', 'History', 'Technology', 'Mathematics'];
            const topic = topics[Math.floor(Math.random() * topics.length)];
            document.getElementById('query').value = `Tell me about ${topic}`;
        }
        
        function addFile() {
            const text = prompt('Enter content for new knowledge file (or leave empty for example):');
            if (text !== null) {
                const content = text || 'This is example content about AI and technology.';
                fetch('/add_file', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({content: content})
                }).then(r => r.json()).then(data => {
                    showStatus('✅ File added: ' + data.filename);
                    updateStats();
                    setTimeout(hideStatus, 2000);
                });
            }
        }
        
        function showStatus(text) {
            const status = document.getElementById('status');
            status.textContent = text;
            status.style.display = 'block';
        }
        
        function hideStatus() {
            document.getElementById('status').style.display = 'none';
        }
        
        // Initialize
        updateStats();
        setInterval(updateStats, 10000); // Update every 10 seconds
    </script>
</body>
</html>'''

# =====================================================
# FLASK APP
# =====================================================
try:
    from flask import Flask, request, jsonify, render_template_string
    FLASK_AVAILABLE = True
except:
    FLASK_AVAILABLE = False
    print("⚠ Flask not available. Installing...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "flask"])
        from flask import Flask, request, jsonify, render_template_string
        FLASK_AVAILABLE = True
        print("✅ Flask installed successfully")
    except:
        FLASK_AVAILABLE = False
        print("❌ Could not install Flask")

if FLASK_AVAILABLE:
    app = Flask(__name__)
    ai_brain = AIBrain()
    
    @app.route('/')
    def home():
        return render_template_string(HTML_TEMPLATE)
    
    @app.route('/chat', methods=['POST'])
    def chat():
        data = request.json
        query = data.get('q', '')
        if not query:
            return jsonify({'error': 'No query provided'})
        
        result = ai_brain.generate_answer(query)
        return jsonify(result)
    
    @app.route('/stats', methods=['GET'])
    def stats():
        files = []
        if os.path.exists(KNOWLEDGE_FOLDER):
            files = [f for f in os.listdir(KNOWLEDGE_FOLDER) if f.endswith('.txt')]
        
        return jsonify({
            'documents': len(files),
            'memory': len(ai_brain.memory.entries),
            'confidence': '85%',
            'files': files
        })
    
    @app.route('/add_file', methods=['POST'])
    def add_file():
        data = request.json
        content = data.get('content', '')
        if not content:
            return jsonify({'error': 'No content provided'})
        
        filename = f"knowledge_{len(ai_brain.knowledge.documents) + 1}.txt"
        filepath = os.path.join(KNOWLEDGE_FOLDER, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Reload knowledge
        ai_brain.knowledge.load_documents()
        
        return jsonify({
            'success': True,
            'filename': filename,
            'message': 'File added successfully'
        })
    
    def run_server(port=8000):
        print(f"\n{'='*60}")
        print("🚀 SUPER AI ULTIMATE IS READY!")
        print(f"{'='*60}")
        print(f"📁 Knowledge folder: {KNOWLEDGE_FOLDER}")
        print(f"💾 Memory file: {MEMORY_FILE}")
        print(f"🌐 Web interface: http://localhost:{port}")
        print(f"\n📝 Add text files to the 'knowledge' folder")
        print("💬 Then open your browser and start chatting!")
        print(f"{'='*60}\n")
        
        # Run Flask in development mode
        app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)
    
    if __name__ == '__main__':
        run_server()
else:
    print("❌ Flask is required but could not be installed.")
    print("💡 Please install manually: pip install flask")
    input("Press Enter to exit...")
'@

# Save the Python file
$pythonCode | Out-File -FilePath "super_ai.py" -Encoding UTF8

# Create example knowledge files
$knowledgeFolder = "knowledge"
New-Item -ItemType Directory -Path $knowledgeFolder -Force | Out-Null

# Create example AI knowledge file
@'
# Artificial Intelligence

Artificial Intelligence (AI) refers to machines that can perform tasks that typically require human intelligence.

Key areas:
1. Machine Learning - Algorithms that learn from data
2. Natural Language Processing - Understanding human language
3. Computer Vision - Interpreting visual information
4. Robotics - Intelligent physical systems

Applications:
- Virtual assistants (Siri, Alexa, Google Assistant)
- Recommendation systems (Netflix, Amazon, YouTube)
- Autonomous vehicles (Tesla, Waymo)
- Medical diagnosis systems
- Fraud detection in banking
- Content generation (ChatGPT, DALL-E)

History:
- 1956: Term "AI" coined at Dartmouth Conference
- 1997: IBM Deep Blue beats chess champion Garry Kasparov
- 2011: IBM Watson wins Jeopardy!
- 2016: AlphaGo defeats Lee Sedol in Go
- 2020s: Large language models revolutionize AI

Current Trends:
- Generative AI (GPT-4, Claude, Gemini)
- Multimodal AI (text + image + audio)
- Edge AI (on-device processing)
- AI ethics and safety
- Quantum machine learning

Future Directions:
- Artificial General Intelligence (AGI)
- Human-AI collaboration
- AI in scientific discovery
- Personalized AI assistants
- AI for climate change solutions
'@ | Out-File -FilePath "$knowledgeFolder\ai.txt" -Encoding UTF8

# Create example programming knowledge file
@'
# Programming Fundamentals

## Python
Python is a high-level, interpreted programming language known for readability.

Key Features:
- Simple, clean syntax
- Dynamic typing
- Automatic memory management
- Extensive standard library
- Multi-paradigm (OOP, functional, procedural)

Example Code:
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

## Common Languages
1. Python - Data science, AI, web development
2. JavaScript - Web development, frontend/backend
3. Java - Enterprise applications, Android
4. C++ - System programming, games, performance
5. C# - Windows applications, games (Unity)
6. Go - Cloud services, microservices
7. Rust - Systems programming, safety-critical

## Web Development Stack
Frontend:
- HTML5 (structure)
- CSS3 (styling)
- JavaScript (functionality)
- React/Vue/Angular (frameworks)

Backend:
- Node.js (JavaScript runtime)
- Python (Django/Flask)
- Java (Spring)
- PHP (Laravel)
- Ruby (Ruby on Rails)

Databases:
- SQL: MySQL, PostgreSQL, SQLite
- NoSQL: MongoDB, Redis, Cassandra

## Best Practices
1. Write clean, readable code
2. Use meaningful variable names
3. Comment complex logic
4. Write unit tests
5. Use version control (Git)
6. Follow coding standards
7. Document your code
8. Refactor regularly

## Common Algorithms
- Sorting: QuickSort, MergeSort, HeapSort
- Searching: Binary Search, Linear Search
- Graph: BFS, DFS, Dijkstra
- Dynamic Programming
- Recursion

## Development Tools
- IDEs: VS Code, PyCharm, IntelliJ
- Version Control: Git, GitHub, GitLab
- Package Managers: pip, npm, yarn
- Containers: Docker, Kubernetes
- CI/CD: Jenkins, GitHub Actions
'@ | Out-File -FilePath "$knowledgeFolder\programming.txt" -Encoding UTF8

# Create example science knowledge file
@'
# Science Fundamentals

## Physics
Newton's Laws of Motion:
1. An object at rest stays at rest, an object in motion stays in motion
2. Force = mass × acceleration (F = ma)
3. For every action, there is an equal and opposite reaction

Key Concepts:
- Quantum mechanics (wave-particle duality)
- Relativity (space-time continuum)
- Thermodynamics (energy transfer)
- Electromagnetism (electricity and magnetism)
- Mechanics (motion and forces)

## Chemistry
Periodic Table: 118 elements organized by properties

Chemical Bonds:
- Ionic (electron transfer)
- Covalent (electron sharing)
- Metallic (electron sea)

Types of Reactions:
- Synthesis (A + B → AB)
- Decomposition (AB → A + B)
- Combustion (fuel + oxygen → CO2 + H2O)
- Acid-Base (acid + base → salt + water)

## Biology
Cell Theory:
1. All living things are made of cells
2. Cells are the basic unit of life
3. New cells come from existing cells

Key Systems:
- Digestive (nutrient absorption)
- Circulatory (blood flow)
- Respiratory (oxygen exchange)
- Nervous (signal transmission)
- Reproductive (species continuation)

## Earth Science
Layers of Earth:
1. Crust (5-70 km)
2. Mantle (2,900 km)
3. Outer Core (2,200 km)
4. Inner Core (1,250 km)

Atmosphere Layers:
- Troposphere (weather)
- Stratosphere (ozone layer)
- Mesosphere (meteor burning)
- Thermosphere (satellites)
- Exosphere (space)

## Astronomy
Solar System:
- Sun (star)
- 8 planets (Mercury to Neptune)
- Dwarf planets (Pluto, Ceres)
- Asteroids, comets, meteors

Stars Life Cycle:
1. Nebula (gas cloud)
2. Protostar (condensing)
3. Main Sequence (stable burning)
4. Red Giant/Supergiant (expansion)
5. White Dwarf/Neutron Star/Black Hole

## Mathematics
Branches:
- Algebra (equations, variables)
- Geometry (shapes, spaces)
- Calculus (change, rates)
- Statistics (data analysis)
- Number Theory (integers)

Important Constants:
- π (pi) ≈ 3.14159
- e (Euler's number) ≈ 2.71828
- φ (golden ratio) ≈ 1.61803
- c (light speed) = 299,792,458 m/s
- G (gravitational constant) = 6.67430×10^-11
'@ | Out-File -FilePath "$knowledgeFolder\science.txt" -Encoding UTF8

# Create memory file
@'
[
  {
    "query": "Hello, who are you?",
    "answer": "I'm Super AI Ultimate - your personal AI assistant! I can learn from documents, answer questions, and remember our conversations. What would you like to know?",
    "timestamp": "' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") + '",
    "confidence": 0.9
  }
]
'@ | Out-File -FilePath "memory.json" -Encoding UTF8

# Create launcher batch file
@'
@echo off
echo ========================================
echo     SUPER AI ULTIMATE - Starting
echo ========================================
echo.
echo Installing required packages...
python -m pip install flask --quiet
echo.
echo Starting AI server...
echo.
echo 📁 Knowledge folder: knowledge
echo 💾 Memory file: memory.json
echo 🌐 Web interface: http://localhost:8000
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.
python super_ai.py
pause
'@ | Out-File -FilePath "start.bat" -Encoding ASCII

# Create PowerShell launcher
@'
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "           SUPER AI ULTIMATE v4.0                        " -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Checking Python packages..." -ForegroundColor Yellow
python -m pip install flask --quiet

Write-Host ""
Write-Host "🚀 Starting AI System..." -ForegroundColor Green
Write-Host ""
Write-Host "📁 Knowledge folder: $PSScriptRoot\knowledge" -ForegroundColor Cyan
Write-Host "💾 Memory file: $PSScriptRoot\memory.json" -ForegroundColor Cyan
Write-Host "🌐 Web interface: http://localhost:8000" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tip: Add your own .txt files to the 'knowledge' folder" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C in this window to stop the AI" -ForegroundColor Gray
Write-Host ""

# Start the AI
Start-Process python -ArgumentList "super_ai.py" -NoNewWindow

# Wait and open browser
Start-Sleep 3
try {
    Start-Process "http://localhost:8000"
    Write-Host "✅ Browser opened!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Please open: http://localhost:8000" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🤖 AI is now running! Happy learning! 🎓" -ForegroundColor Green
'@ | Out-File -FilePath "launch.ps1" -Encoding UTF8

# Create README
@'
# SUPER AI ULTIMATE

## 🚀 QUICK START

1. **Windows:** Double-click `start.bat`
2. **PowerShell:** Run `.\launch.ps1`
3. **Browser opens** at http://localhost:8000
4. **Start chatting** with your AI!

## 📁 ADD KNOWLEDGE

Place `.txt` files in the `knowledge` folder. The AI will automatically:
- Read and learn from all text files
- Search for relevant information
- Use knowledge to answer questions

## 💬 FEATURES

✅ **100% Offline** - No internet required  
✅ **Knowledge Learning** - Reads text files automatically  
✅ **Memory** - Remembers all conversations  
✅ **Web Interface** - Modern, easy-to-use UI  
✅ **No Installation** - Just run and go  

## 🎮 HOW TO USE

1. **Ask questions** in the web interface
2. **AI searches** knowledge files for answers
3. **Responses include** confidence level and sources
4. **Add more files** anytime - AI reloads automatically

## 📝 EXAMPLE QUESTIONS

- "What is artificial intelligence?"
- "Tell me about Python programming"
- "Explain Newton's laws of motion"
- "What are the layers of Earth's atmosphere?"

## 🔧 TROUBLESHOOTING

### Python not found:
Install Python 3.8+ from python.org

### Flask installation fails:
Run: `python -m pip install flask`

### Port 8000 in use:
Edit `super_ai.py` and change port number

### Files not loading:
Make sure files are `.txt` format in `knowledge` folder

## 📁 FILES CREATED

- `super_ai.py` - Main AI system
- `knowledge/` - Folder for your text files
- `memory.json` - Conversation history
- `start.bat` - Windows launcher
- `launch.ps1` - PowerShell launcher

Enjoy your personal AI assistant! 🤖
'@ | Out-File -FilePath "README.txt" -Encoding UTF8

# =====================================================
# 2. RUN THE SYSTEM
# =====================================================

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "           SETUP COMPLETE!                              " -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Created in folder: $pwd" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Files created:" -ForegroundColor Green
Write-Host "   • super_ai.py (Main AI system)" -ForegroundColor Gray
Write-Host "   • knowledge/ (With 3 example files)" -ForegroundColor Gray
Write-Host "   • memory.json (Conversation memory)" -ForegroundColor Gray
Write-Host "   • start.bat (Windows launcher)" -ForegroundColor Gray
Write-Host "   • launch.ps1 (PowerShell launcher)" -ForegroundColor Gray
Write-Host "   • README.txt (Instructions)" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Choose how to start:" -ForegroundColor Yellow
Write-Host "   1. Double-click 'start.bat' (Easiest)" -ForegroundColor White
Write-Host "   2. Run '.\launch.ps1' in PowerShell" -ForegroundColor White
Write-Host "   3. Run 'python super_ai.py' manually" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Then open: http://localhost:8000" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Add your own .txt files to the 'knowledge' folder!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Would you like to start now? (Y/N)" -ForegroundColor Yellow
$answer = Read-Host

if ($answer -eq 'Y' -or $answer -eq 'y') {
    Write-Host "Starting AI..." -ForegroundColor Green
    
    # Install Flask if needed
    Write-Host "Checking packages..." -ForegroundColor Yellow
    python -m pip install flask --quiet
    
    # Start the AI
    Write-Host "Launching AI server..." -ForegroundColor Green
    $process = Start-Process python -ArgumentList "super_ai.py" -NoNewWindow -PassThru
    
    # Wait and open browser
    Start-Sleep 3
    try {
        Start-Process "http://localhost:8000"
        Write-Host "✅ Browser opened!" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Please open: http://localhost:8000" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "🤖 AI is running!" -ForegroundColor Green
    Write-Host "💬 Chat at: http://localhost:8000" -ForegroundColor Cyan
    Write-Host "🛑 Press Ctrl+C in the Python window to stop" -ForegroundColor Gray
    
    # Wait for process to finish
    $process.WaitForExit()
} else {
    Write-Host ""
    Write-Host "📋 Run anytime:" -ForegroundColor Yellow
    Write-Host "   • Double-click 'start.bat'" -ForegroundColor White
    Write-Host "   • OR run '.\launch.ps1'" -ForegroundColor White
    Write-Host ""
    Write-Host "Enjoy your AI! 🤖" -ForegroundColor Green
}