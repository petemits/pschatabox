# =====================================================
# AI CONVERSATION ENGINE 2025 - SINGLE FILE
# =====================================================
# Save as AIUltimate.ps1 and run it
# Features: Tiny models, endless conversation, multi-format parsing, voice I/O
# =====================================================

# Clean setup
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Create directory
$ROOT = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$AI_DIR = "$ROOT\AIConversationEngine"
if (!(Test-Path $AI_DIR)) { New-Item -ItemType Directory -Path $AI_DIR -Force | Out-Null }
Set-Location $AI_DIR

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                 AI CONVERSATION ENGINE 2025                             ║" -ForegroundColor Yellow
Write-Host "║          Tiny Models • Endless Talk • Multi-Format • Voice              ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# =====================================================
# CREATE MAIN PYTHON SYSTEM
# =====================================================
Write-Host "[1/5] 🤖 Creating AI Conversation Engine..." -ForegroundColor Green

$aiCode = @'
# =====================================================
# AI CONVERSATION ENGINE 2025
# =====================================================
import os, sys, json, re, random, time, threading, hashlib, datetime, math, base64
import subprocess, tempfile, traceback, zipfile, pickle, csv, sqlite3, mimetypes
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple, Union
from dataclasses import dataclass, asdict, field
from collections import defaultdict, deque
from enum import Enum
import numpy as np

print("🚀 Starting AI Conversation Engine 2025...")

# =====================================================
# CONFIGURATION
# =====================================================
ROOT = Path(__file__).parent.absolute()
CONFIG = {
    "system": {
        "name": "AI Conversation Engine 2025",
        "version": "1.0.0",
        "tiny_model": True,
        "max_conversation_history": 50,
        "learning_rate": 0.1,
        "exploration_rate": 0.3
    },
    "conversation": {
        "max_turns": 1000,
        "topic_change_prob": 0.2,
        "depth_change_prob": 0.15,
        "emotion_variation": True,
        "personality_traits": ["curious", "helpful", "analytical", "creative"]
    },
    "knowledge": {
        "auto_load": True,
        "supported_formats": [".txt", ".pdf", ".docx", ".xlsx", ".xls", ".csv", ".json", ".md", ".jpg", ".png", ".jpeg"],
        "max_file_size_mb": 50,
        "ocr_enabled": True
    },
    "voice": {
        "enabled": True,
        "tts_rate": 160,
        "tts_volume": 0.9,
        "stt_timeout": 8
    }
}

# Paths
KNOWLEDGE_FOLDER = ROOT / "knowledge"
MEMORY_DB = ROOT / "memory.db"
MODELS_FOLDER = ROOT / "models"
LOGS_FOLDER = ROOT / "logs"
WEB_CACHE = ROOT / "web_cache"

# Create folders
for folder in [KNOWLEDGE_FOLDER, MODELS_FOLDER, LOGS_FOLDER, WEB_CACHE]:
    folder.mkdir(exist_ok=True)

# =====================================================
# TINY NLP MODEL - FAST & LOCAL
# =====================================================
class TinyNLP:
    """Ultra-fast local NLP with minimal dependencies"""
    
    def __init__(self):
        print("🧠 Loading Tiny NLP model...")
        self.vocab = set()
        self.word_vectors = {}
        self.topic_vectors = {}
        self._init_model()
        self._load_pretrained_tiny()
    
    def _init_model(self):
        """Initialize tiny word vectors"""
        # Basic semantic relationships
        semantic_groups = {
            "ai": ["artificial", "intelligence", "machine", "learning", "neural", "network", "algorithm", "data"],
            "tech": ["technology", "computer", "software", "hardware", "digital", "code", "program", "system"],
            "science": ["science", "physics", "chemistry", "biology", "research", "experiment", "theory", "discovery"],
            "math": ["mathematics", "calculate", "equation", "algebra", "geometry", "statistics", "number", "logic"],
            "people": ["human", "person", "people", "individual", "society", "community", "culture", "relationship"],
            "emotion": ["happy", "sad", "angry", "excited", "curious", "interested", "surprised", "confused"],
            "time": ["time", "past", "present", "future", "now", "then", "soon", "later", "before", "after"],
            "space": ["space", "universe", "world", "earth", "planet", "star", "galaxy", "cosmos"]
        }
        
        # Create simple vectors
        vector_size = 50
        for group_name, words in semantic_groups.items():
            # Create group vector
            group_vector = np.random.randn(vector_size)
            group_vector = group_vector / np.linalg.norm(group_vector)
            self.topic_vectors[group_name] = group_vector
            
            # Assign words to group with some noise
            for word in words:
                noise = np.random.randn(vector_size) * 0.1
                self.word_vectors[word] = group_vector + noise
                self.word_vectors[word] = self.word_vectors[word] / np.linalg.norm(self.word_vectors[word])
                self.vocab.add(word)
        
        print(f"✓ Tiny NLP model loaded: {len(self.vocab)} words, {len(self.topic_vectors)} topics")
    
    def _load_pretrained_tiny(self):
        """Try to load tiny pretrained model if available"""
        tiny_model_path = MODELS_FOLDER / "tiny_embeddings.npy"
        if tiny_model_path.exists():
            try:
                data = np.load(tiny_model_path, allow_pickle=True).item()
                self.word_vectors.update(data.get('word_vectors', {}))
                self.topic_vectors.update(data.get('topic_vectors', {}))
                print(f"✓ Loaded pretrained tiny embeddings")
            except:
                pass
    
    def save_model(self):
        """Save the tiny model"""
        try:
            data = {
                'word_vectors': self.word_vectors,
                'topic_vectors': self.topic_vectors,
                'vocab': list(self.vocab)
            }
            np.save(MODELS_FOLDER / "tiny_embeddings.npy", data)
        except:
            pass
    
    def get_vector(self, text: str) -> np.ndarray:
        """Get vector for text"""
        words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())
        if not words:
            return np.zeros(50)
        
        vectors = []
        for word in words:
            if word in self.word_vectors:
                vectors.append(self.word_vectors[word])
            else:
                # Create new vector for unknown word
                new_vec = np.random.randn(50)
                new_vec = new_vec / np.linalg.norm(new_vec)
                self.word_vectors[word] = new_vec
                self.vocab.add(word)
                vectors.append(new_vec)
        
        if vectors:
            return np.mean(vectors, axis=0)
        return np.zeros(50)
    
    def similarity(self, text1: str, text2: str) -> float:
        """Calculate semantic similarity"""
        vec1 = self.get_vector(text1)
        vec2 = self.get_vector(text2)
        
        norm1 = np.linalg.norm(vec1)
        norm2 = np.linalg.norm(vec2)
        
        if norm1 == 0 or norm2 == 0:
            return 0.0
        
        return np.dot(vec1, vec2) / (norm1 * norm2)
    
    def detect_topics(self, text: str, top_k: int = 3) -> List[Tuple[str, float]]:
        """Detect topics in text"""
        text_vec = self.get_vector(text)
        topics = []
        
        for topic_name, topic_vec in self.topic_vectors.items():
            similarity = np.dot(text_vec, topic_vec) / (
                np.linalg.norm(text_vec) * np.linalg.norm(topic_vec)
            )
            if similarity > 0.1:
                topics.append((topic_name, float(similarity)))
        
        topics.sort(key=lambda x: x[1], reverse=True)
        return topics[:top_k]
    
    def extract_keywords(self, text: str, top_n: int = 5) -> List[str]:
        """Extract important keywords"""
        words = re.findall(r'\b[a-zA-Z]{4,}\b', text.lower())
        word_freq = defaultdict(int)
        
        for word in words:
            word_freq[word] += 1
        
        # Boost importance of topic-related words
        topics = self.detect_topics(text)
        topic_words = set()
        for topic, _ in topics:
            topic_words.update(topic.split())
        
        for word in word_freq:
            if word in topic_words:
                word_freq[word] *= 2
        
        return [word for word, _ in sorted(word_freq.items(), key=lambda x: x[1], reverse=True)[:top_n]]

# =====================================================
# DOCUMENT PARSER - MULTI-FORMAT
# =====================================================
class DocumentParser:
    """Parse PDF, DOCX, Excel, Images, etc."""
    
    def __init__(self):
        self.parsers = {}
        self._init_parsers()
    
    def _init_parsers(self):
        """Initialize all document parsers"""
        try:
            import PyPDF2
            self.parsers['pdf'] = PyPDF2
            print("✓ PDF parser ready")
        except:
            print("⚠ PDF parser not available")
        
        try:
            import pandas as pd
            self.parsers['pandas'] = pd
            print("✓ Excel parser ready")
        except:
            print("⚠ Excel parser not available")
        
        try:
            from docx import Document as DocxDocument
            self.parsers['docx'] = DocxDocument
            print("✓ DOCX parser ready")
        except:
            print("⚠ DOCX parser not available")
        
        try:
            from PIL import Image
            import pytesseract
            self.parsers['pil'] = Image
            self.parsers['tesseract'] = pytesseract
            print("✓ Image OCR ready")
        except:
            print("⚠ Image OCR not available")
        
        try:
            from bs4 import BeautifulSoup
            self.parsers['bs4'] = BeautifulSoup
            print("✓ HTML parser ready")
        except:
            print("⚠ HTML parser not available")
    
    def parse_file(self, file_path: Path) -> Tuple[str, Dict]:
        """Parse any file type"""
        if not file_path.exists():
            return "", {"error": "File not found"}
        
        ext = file_path.suffix.lower()
        metadata = {
            "name": file_path.name,
            "size": file_path.stat().st_size,
            "type": ext[1:],
            "parsed": False
        }
        
        content = ""
        
        try:
            # Text files
            if ext in ['.txt', '.md', '.json', '.csv', '.html', '.xml']:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                metadata['parsed'] = True
            
            # PDF files
            elif ext == '.pdf' and 'pdf' in self.parsers:
                pdf = self.parsers['pdf']
                with open(file_path, 'rb') as f:
                    reader = pdf.PdfReader(f)
                    pages = []
                    for page in reader.pages[:20]:  # Limit pages
                        text = page.extract_text()
                        if text:
                            pages.append(text)
                    content = ' '.join(pages)
                metadata['parsed'] = True
            
            # DOCX files
            elif ext == '.docx' and 'docx' in self.parsers:
                doc = self.parsers['docx'](file_path)
                content = ' '.join([para.text for para in doc.paragraphs if para.text])
                metadata['parsed'] = True
            
            # Excel files
            elif ext in ['.xlsx', '.xls'] and 'pandas' in self.parsers:
                pd = self.parsers['pandas']
                try:
                    df = pd.read_excel(file_path, sheet_name=None)
                    sheets = []
                    for sheet_name, data in df.items():
                        sheets.append(f"Sheet: {sheet_name}")
                        sheets.append(data.to_string())
                    content = '\n'.join(sheets)
                    metadata['parsed'] = True
                except:
                    content = f"Could not parse Excel file: {file_path.name}"
            
            # Images
            elif ext in ['.jpg', '.jpeg', '.png', '.bmp'] and all(k in self.parsers for k in ['pil', 'tesseract']):
                try:
                    Image = self.parsers['pil']
                    pytesseract = self.parsers['tesseract']
                    img = Image.open(file_path)
                    content = pytesseract.image_to_string(img)
                    metadata['parsed'] = True
                except:
                    content = f"Could not OCR image: {file_path.name}"
            
            else:
                content = f"Unsupported format: {ext}"
        
        except Exception as e:
            content = f"Error parsing {file_path.name}: {str(e)}"
            metadata['error'] = str(e)
        
        return content, metadata

# =====================================================
# KNOWLEDGE GRAPH - SEMANTIC MEMORY
# =====================================================
class KnowledgeGraph:
    """Semantic knowledge graph for endless conversation"""
    
    def __init__(self, nlp: TinyNLP):
        self.nlp = nlp
        self.nodes = {}  # id -> node data
        self.edges = defaultdict(list)  # source -> [(target, weight)]
        self.topics = defaultdict(list)
        self.conversation_history = deque(maxlen=100)
        self.load()
    
    def add_document(self, content: str, source: str):
        """Add document to knowledge graph"""
        doc_id = hashlib.md5(content.encode()).hexdigest()
        
        # Extract key information
        paragraphs = [p.strip() for p in content.split('\n') if len(p.strip()) > 50]
        
        for para in paragraphs[:20]:  # Limit paragraphs per document
            para_id = hashlib.md5(para.encode()).hexdigest()
            
            # Create node
            self.nodes[para_id] = {
                'id': para_id,
                'content': para,
                'source': source,
                'vector': self.nlp.get_vector(para),
                'topics': self.nlp.detect_topics(para),
                'keywords': self.nlp.extract_keywords(para),
                'timestamp': datetime.datetime.now()
            }
            
            # Add to topics
            for topic, score in self.nodes[para_id]['topics']:
                self.topics[topic].append(para_id)
            
            # Connect with similar existing nodes
            for other_id, other_node in list(self.nodes.items()):
                if other_id != para_id:
                    similarity = self.nlp.similarity(para, other_node['content'])
                    if similarity > 0.3:
                        self.edges[para_id].append((other_id, similarity))
                        self.edges[other_id].append((para_id, similarity))
        
        print(f"📄 Added document: {source} ({len(paragraphs)} paragraphs)")
    
    def search(self, query: str, top_k: int = 5) -> List[Dict]:
        """Search knowledge graph"""
        query_vec = self.nlp.get_vector(query)
        results = []
        
        for node_id, node in self.nodes.items():
            if hasattr(node['vector'], 'shape'):
                similarity = np.dot(query_vec, node['vector']) / (
                    np.linalg.norm(query_vec) * np.linalg.norm(node['vector'])
                )
            else:
                similarity = 0.0
            
            if similarity > 0.1:
                results.append({
                    'id': node_id,
                    'content': node['content'],
                    'similarity': float(similarity),
                    'source': node['source'],
                    'topics': node['topics']
                })
        
        results.sort(key=lambda x: x['similarity'], reverse=True)
        return results[:top_k]
    
    def get_related_nodes(self, node_id: str, depth: int = 2) -> List[Dict]:
        """Get related nodes in graph"""
        visited = set()
        queue = [(node_id, 0)]
        related = []
        
        while queue:
            current_id, current_depth = queue.pop(0)
            if current_id in visited or current_depth > depth:
                continue
            
            visited.add(current_id)
            if current_id in self.nodes:
                related.append(self.nodes[current_id])
            
            # Add neighbors
            for neighbor_id, weight in self.edges.get(current_id, []):
                if neighbor_id not in visited:
                    queue.append((neighbor_id, current_depth + 1))
        
        return related
    
    def suggest_conversation_topic(self, current_topic: str = None) -> Dict:
        """Suggest new conversation topic"""
        if current_topic and random.random() < 0.7:
            # Explore related topics
            current_vec = self.nlp.get_vector(current_topic)
            best_topic = current_topic
            best_similarity = 0.0
            
            for topic in self.topics.keys():
                topic_vec = self.nlp.get_vector(topic)
                similarity = np.dot(current_vec, topic_vec) / (
                    np.linalg.norm(current_vec) * np.linalg.norm(topic_vec)
                )
                
                # Slight variation for exploration
                if 0.3 < similarity < 0.8:
                    if similarity > best_similarity:
                        best_similarity = similarity
                        best_topic = topic
        
        else:
            # Random new topic
            topics = list(self.topics.keys())
            if topics:
                best_topic = random.choice(topics)
            else:
                best_topic = random.choice(["science", "technology", "art", "history", "philosophy"])
        
        # Get content for topic
        topic_nodes = self.topics.get(best_topic, [])
        if topic_nodes:
            node_id = random.choice(topic_nodes[:10])
            content = self.nodes.get(node_id, {}).get('content', f"Let's discuss {best_topic}.")
        else:
            content = f"I'd like to learn more about {best_topic}. What do you think about it?"
        
        return {
            'topic': best_topic,
            'content': content,
            'type': 'exploration' if random.random() < 0.3 else 'continuation'
        }
    
    def add_conversation_turn(self, user_input: str, ai_response: str):
        """Add conversation to history"""
        turn = {
            'user': user_input,
            'ai': ai_response,
            'timestamp': datetime.datetime.now(),
            'topics': self.nlp.detect_topics(user_input + " " + ai_response),
            'keywords': self.nlp.extract_keywords(user_input + " " + ai_response)
        }
        self.conversation_history.append(turn)
        
        # Learn from conversation
        self.add_document(user_input, "conversation")
        self.add_document(ai_response, "conversation")
    
    def get_conversation_pattern(self) -> Dict:
        """Analyze conversation patterns"""
        if len(self.conversation_history) < 3:
            return {"pattern": "initial", "depth": "shallow", "style": "exploratory"}
        
        recent = list(self.conversation_history)[-5:]
        
        # Analyze topic consistency
        topics = []
        for turn in recent:
            topics.extend([t[0] for t in turn['topics']])
        
        from collections import Counter
        topic_counts = Counter(topics)
        
        if topic_counts:
            main_topic = topic_counts.most_common(1)[0][0]
            consistency = topic_counts[main_topic] / len(topics)
        else:
            main_topic = "general"
            consistency = 0.0
        
        # Analyze depth (word count)
        avg_words = sum(len(turn['user'].split()) + len(turn['ai'].split()) for turn in recent) / (len(recent) * 2)
        
        # Determine pattern
        if consistency > 0.6:
            pattern = "focused"
            depth = "deep" if avg_words > 50 else "medium"
        else:
            pattern = "exploratory"
            depth = "shallow"
        
        # Determine style based on keywords
        keywords = set()
        for turn in recent:
            keywords.update(turn['keywords'])
        
        emotional_words = {'happy', 'sad', 'excited', 'curious', 'interesting', 'amazing', 'wonderful'}
        has_emotion = len(keywords & emotional_words) > 0
        
        return {
            "pattern": pattern,
            "depth": depth,
            "style": "emotional" if has_emotion else "analytical",
            "main_topic": main_topic,
            "consistency": consistency
        }
    
    def save(self):
        """Save knowledge graph"""
        try:
            data = {
                'nodes': self.nodes,
                'edges': dict(self.edges),
                'topics': dict(self.topics),
                'conversation_history': list(self.conversation_history)
            }
            with open(MODELS_FOLDER / "knowledge_graph.pkl", 'wb') as f:
                pickle.dump(data, f)
        except:
            pass
    
    def load(self):
        """Load knowledge graph"""
        try:
            graph_path = MODELS_FOLDER / "knowledge_graph.pkl"
            if graph_path.exists():
                with open(graph_path, 'rb') as f:
                    data = pickle.load(f)
                    self.nodes = data.get('nodes', {})
                    self.edges = defaultdict(list, data.get('edges', {}))
                    self.topics = defaultdict(list, data.get('topics', {}))
                    self.conversation_history = deque(
                        data.get('conversation_history', []),
                        maxlen=100
                    )
                print(f"✓ Loaded knowledge graph: {len(self.nodes)} nodes, {len(self.topics)} topics")
        except:
            self.nodes = {}
            self.edges = defaultdict(list)
            self.topics = defaultdict(list)
            self.conversation_history = deque(maxlen=100)

# =====================================================
# CONVERSATION ENGINE - ENDLESS TALK
# =====================================================
class ConversationEngine:
    """Generate endless human-like conversations"""
    
    def __init__(self, nlp: TinyNLP, knowledge_graph: KnowledgeGraph):
        self.nlp = nlp
        self.graph = knowledge_graph
        self.personality = CONFIG['conversation']['personality_traits']
        self.emotion_state = "neutral"
        self.conversation_depth = 1
        self.topic_history = []
        self.response_patterns = self._load_patterns()
        
        # Conversation templates
        self.templates = {
            "question": [
                "What are your thoughts on {topic}?",
                "Have you considered {idea}?",
                "I'm curious about {topic}. What do you think?",
                "What's your perspective on {topic}?",
                "How do you feel about {topic}?"
            ],
            "elaboration": [
                "That's interesting! Could you elaborate on {point}?",
                "Tell me more about {topic}.",
                "I'd like to understand {concept} better.",
                "What makes {topic} so fascinating to you?",
                "Could you expand on that idea?"
            ],
            "connection": [
                "This reminds me of {related_topic}.",
                "That connects to {concept} in an interesting way.",
                "This relates to {field} as well.",
                "I see a parallel with {similar_idea}.",
                "This makes me think about {connection}."
            ],
            "reflection": [
                "So you're saying that {summary}?",
                "If I understand correctly, {interpretation}",
                "Let me reflect that back: {reflection}",
                "So the key point is {key_point}?",
                "What I'm hearing is {understanding}"
            ],
            "exploration": [
                "What if we consider {alternative}?",
                "How would {scenario} change things?",
                "What are the implications of {idea}?",
                "Where could {concept} lead us?",
                "What's the bigger picture here?"
            ]
        }
    
    def _load_patterns(self) -> Dict:
        """Load conversation patterns"""
        return {
            "q-a": ["question", "answer", "followup"],
            "discussion": ["statement", "response", "elaboration", "connection"],
            "debate": ["claim", "counter", "evidence", "rebuttal"],
            "exploration": ["question", "speculation", "analysis", "synthesis"],
            "story": ["setup", "development", "climax", "resolution"]
        }
    
    def analyze_input(self, user_input: str) -> Dict:
        """Analyze user input for conversation generation"""
        # Extract topics
        topics = self.nlp.detect_topics(user_input)
        
        # Extract intent
        intent = self._detect_intent(user_input)
        
        # Extract emotion
        emotion = self._detect_emotion(user_input)
        
        # Calculate complexity
        word_count = len(user_input.split())
        sentence_count = len(re.split(r'[.!?]+', user_input))
        
        return {
            "topics": topics,
            "intent": intent,
            "emotion": emotion,
            "complexity": "high" if word_count > 20 else "medium" if word_count > 10 else "low",
            "type": "question" if '?' in user_input else "statement",
            "keywords": self.nlp.extract_keywords(user_input)
        }
    
    def _detect_intent(self, text: str) -> str:
        """Detect user intent"""
        text_lower = text.lower()
        
        if any(word in text_lower for word in ['what', 'how', 'why', 'when', 'where', 'who', 'explain', 'tell me']):
            return "inquire"
        elif any(word in text_lower for word in ['think', 'opinion', 'view', 'perspective']):
            return "seek_opinion"
        elif any(word in text_lower for word in ['help', 'assist', 'guide', 'show']):
            return "request_help"
        elif any(word in text_lower for word in ['yes', 'no', 'agree', 'disagree', 'correct', 'wrong']):
            return "respond"
        elif any(word in text_lower for word in ['because', 'reason', 'cause', 'since']):
            return "explain"
        else:
            return "share"
    
    def _detect_emotion(self, text: str) -> str:
        """Detect emotional tone"""
        text_lower = text.lower()
        emotional_words = {
            "happy": ['happy', 'excited', 'great', 'wonderful', 'amazing', 'love', 'awesome'],
            "sad": ['sad', 'unhappy', 'disappointed', 'bad', 'terrible', 'hate'],
            "curious": ['curious', 'interesting', 'fascinating', 'wonder', 'question'],
            "angry": ['angry', 'mad', 'frustrated', 'annoyed', 'upset'],
            "neutral": []
        }
        
        for emotion, words in emotional_words.items():
            if any(word in text_lower for word in words):
                return emotion
        
        # Check punctuation
        if '!' in text:
            return "excited"
        elif '...' in text or '..' in text:
            return "thoughtful"
        
        return "neutral"
    
    def generate_response(self, user_input: str, analysis: Dict, context: List[Dict] = None) -> str:
        """Generate conversational response"""
        
        # Get knowledge context
        knowledge_results = self.graph.search(user_input, top_k=3)
        knowledge_context = ""
        if knowledge_results:
            knowledge_context = " ".join([r['content'][:200] for r in knowledge_results[:2]])
        
        # Decide conversation strategy
        strategy = self._choose_strategy(analysis, context)
        
        # Generate response based on strategy
        if strategy == "knowledge_based" and knowledge_context:
            response = self._generate_knowledge_response(user_input, knowledge_context, analysis)
        elif strategy == "exploratory":
            response = self._generate_exploratory_response(user_input, analysis)
        elif strategy == "emotional":
            response = self._generate_emotional_response(user_input, analysis)
        elif strategy == "analytical":
            response = self._generate_analytical_response(user_input, analysis)
        else:
            response = self._generate_general_response(user_input, analysis)
        
        # Add variation
        response = self._add_conversational_variation(response, analysis)
        
        # Update conversation state
        self._update_state(user_input, response, analysis)
        
        return response
    
    def _choose_strategy(self, analysis: Dict, context: List[Dict] = None) -> str:
        """Choose conversation strategy"""
        patterns = self.graph.get_conversation_pattern()
        
        if analysis['emotion'] != "neutral":
            return "emotional"
        elif patterns['depth'] == "deep":
            return "analytical"
        elif len(self.topic_history) > 5 and random.random() < 0.3:
            return "exploratory"
        elif random.random() < 0.4:
            return "knowledge_based"
        else:
            return "general"
    
    def _generate_knowledge_response(self, user_input: str, knowledge: str, analysis: Dict) -> str:
        """Generate response based on knowledge"""
        template = random.choice([
            "Based on what I know, {knowledge}. What's your take on this?",
            "I've learned that {knowledge}. How does this relate to your question?",
            "From my understanding, {knowledge}. Does this align with your thoughts?",
            "There's information suggesting {knowledge}. What's your perspective?"
        ])
        
        # Extract key phrase from knowledge
        knowledge_phrases = [s.strip() for s in knowledge.split('.') if len(s.strip()) > 20]
        if knowledge_phrases:
            key_phrase = random.choice(knowledge_phrases[:3])
        else:
            key_phrase = knowledge[:100]
        
        return template.format(knowledge=key_phrase)
    
    def _generate_exploratory_response(self, user_input: str, analysis: Dict) -> str:
        """Generate exploratory response"""
        topics = [t[0] for t in analysis['topics']]
        if topics:
            topic = random.choice(topics)
        else:
            topic = "this concept"
        
        templates = [
            "That's an interesting angle! What if we consider {topic} from a different perspective?",
            "I'm curious to explore {topic} further. What are some alternative viewpoints?",
            "Let's dive deeper into {topic}. What questions does this raise for you?",
            "This makes me wonder about {topic}. How might this evolve in the future?"
        ]
        
        return random.choice(templates).format(topic=topic)
    
    def _generate_emotional_response(self, user_input: str, analysis: Dict) -> str:
        """Generate emotional response"""
        emotion = analysis['emotion']
        
        emotional_responses = {
            "happy": [
                "That's wonderful to hear! I'm glad you're excited about this.",
                "Your enthusiasm is contagious! This is fascinating.",
                "I love your positive energy! Let's explore this further."
            ],
            "curious": [
                "Your curiosity is inspiring! What specifically interests you about this?",
                "I'm curious too! What questions come to mind for you?",
                "That's a great point to ponder. What do you think might be the answer?"
            ],
            "sad": [
                "I understand this might be challenging. Would you like to approach it differently?",
                "That's a thoughtful perspective. What aspects are most meaningful to you?",
                "I appreciate you sharing this. How would you like to proceed?"
            ],
            "neutral": [
                "That's interesting. What are your thoughts on this?",
                "I see. How does this connect with your experiences?",
                "Thanks for sharing. What would you like to explore next?"
            ]
        }
        
        return random.choice(emotional_responses.get(emotion, emotional_responses["neutral"]))
    
    def _generate_analytical_response(self, user_input: str, analysis: Dict) -> str:
        """Generate analytical response"""
        keywords = analysis['keywords']
        if keywords:
            keyword = random.choice(keywords[:3])
        else:
            keyword = "this"
        
        templates = [
            "From an analytical perspective, {keyword} presents several interesting dimensions.",
            "Let's break this down systematically. The key factor seems to be {keyword}.",
            "Analyzing this further, {keyword} appears to be the central component.",
            "Consider the logical implications of {keyword}. How would you evaluate them?"
        ]
        
        return random.choice(templates).format(keyword=keyword)
    
    def _generate_general_response(self, user_input: str, analysis: Dict) -> str:
        """Generate general conversational response"""
        pattern_type = random.choice(list(self.response_patterns.keys()))
        pattern = random.choice(self.response_patterns[pattern_type])
        
        # Map pattern to template
        if pattern == "question":
            topic = random.choice([t[0] for t in analysis['topics']] or ["this topic"])
            return random.choice(self.templates["question"]).format(topic=topic)
        elif pattern == "elaboration":
            point = random.choice(analysis['keywords'] or ["this point"])
            return random.choice(self.templates["elaboration"]).format(point=point)
        elif pattern == "connection":
            topics = [t[0] for t in analysis['topics']]
            if len(topics) > 1:
                related = random.choice(topics[1:])
            else:
                related = "related concepts"
            return random.choice(self.templates["connection"]).format(related_topic=related)
        else:
            return "That's interesting. Tell me more about your thoughts on this."
    
    def _add_conversational_variation(self, response: str, analysis: Dict) -> str:
        """Add natural conversation variations"""
        # Add filler words occasionally
        if random.random() < 0.2:
            fillers = ["Well, ", "You know, ", "Actually, ", "I think ", "In my view, "]
            response = random.choice(fillers) + response.lower()
        
        # Add follow-up questions
        if random.random() < 0.3:
            follow_ups = [
                " What do you think?",
                " How does that sound to you?",
                " Would you agree?",
                " What's your take on this?"
            ]
            response += random.choice(follow_ups)
        
        # Vary sentence length
        sentences = response.split('. ')
        if len(sentences) > 1 and random.random() < 0.4:
            # Mix short and long sentences
            mixed = []
            for i, sentence in enumerate(sentences):
                if i % 2 == 0 and len(sentence.split()) > 8:
                    # Split long sentence
                    words = sentence.split()
                    midpoint = len(words) // 2
                    mixed.append(' '.join(words[:midpoint]) + '.')
                    mixed.append(' '.join(words[midpoint:]))
                else:
                    mixed.append(sentence)
            response = '. '.join(mixed)
        
        return response
    
    def _update_state(self, user_input: str, response: str, analysis: Dict):
        """Update conversation state"""
        # Update emotion based on interaction
        if analysis['emotion'] != "neutral":
            self.emotion_state = analysis['emotion']
        
        # Update topic history
        topics = [t[0] for t in analysis['topics']]
        if topics:
            self.topic_history.append(topics[0])
            if len(self.topic_history) > 10:
                self.topic_history.pop(0)
        
        # Adjust conversation depth
        if analysis['complexity'] == "high":
            self.conversation_depth = min(3, self.conversation_depth + 0.1)
        elif analysis['complexity'] == "low":
            self.conversation_depth = max(1, self.conversation_depth - 0.1)
    
    def suggest_topic_change(self) -> Optional[Dict]:
        """Suggest changing conversation topic"""
        if len(self.topic_history) > 3 and random.random() < CONFIG['conversation']['topic_change_prob']:
            return self.graph.suggest_conversation_topic(
                self.topic_history[-1] if self.topic_history else None
            )
        return None

# =====================================================
# VOICE INTERFACE
# =====================================================
class VoiceInterface:
    """Voice input/output interface"""
    
    def __init__(self):
        self.tts_engine = None
        self.stt_engine = None
        self._init_voice()
    
    def _init_voice(self):
        """Initialize voice engines"""
        if CONFIG['voice']['enabled']:
            try:
                import pyttsx3
                self.tts_engine = pyttsx3.init()
                self.tts_engine.setProperty('rate', CONFIG['voice']['tts_rate'])
                self.tts_engine.setProperty('volume', CONFIG['voice']['tts_volume'])
                print("✓ Voice output ready")
            except:
                print("⚠ Voice output not available")
            
            try:
                import speech_recognition as sr
                self.stt_engine = sr.Recognizer()
                print("✓ Voice input ready")
            except:
                print("⚠ Voice input not available")
    
    def speak(self, text: str):
        """Convert text to speech"""
        if self.tts_engine and text:
            def _speak():
                try:
                    self.tts_engine.say(text[:300])  # Limit length
                    self.tts_engine.runAndWait()
                except Exception as e:
                    print(f"Voice error: {e}")
            
            threading.Thread(target=_speak, daemon=True).start()
    
    def listen(self) -> Optional[str]:
        """Convert speech to text"""
        if not self.stt_engine:
            return None
        
        try:
            import speech_recognition as sr
            
            with sr.Microphone() as source:
                print("🎤 Listening... (speak now)")
                self.stt_engine.adjust_for_ambient_noise(source, duration=0.5)
                audio = self.stt_engine.listen(
                    source, 
                    timeout=CONFIG['voice']['stt_timeout'],
                    phrase_time_limit=15
                )
                
                text = self.stt_engine.recognize_google(audio)
                print(f"🗣 Heard: {text}")
                return text
                
        except sr.WaitTimeoutError:
            print("⏰ Listening timeout")
        except sr.UnknownValueError:
            print("❓ Could not understand audio")
        except Exception as e:
            print(f"🎤 Microphone error: {e}")
        
        return None

# =====================================================
# WEB INTEGRATION
# =====================================================
class WebIntegration:
    """Web scraping and integration"""
    
    def __init__(self):
        self.selenium = None
        self.bs4 = None
        self._init_web_tools()
    
    def _init_web_tools(self):
        """Initialize web tools"""
        try:
            from selenium import webdriver
            from selenium.webdriver.common.by import By
            from selenium.webdriver.support.ui import WebDriverWait
            from selenium.webdriver.support import expected_conditions as EC
            from selenium.webdriver.chrome.options import Options
            
            self.selenium = {
                'webdriver': webdriver,
                'By': By,
                'WebDriverWait': WebDriverWait,
                'EC': EC,
                'Options': Options
            }
            print("✓ Selenium ready for web scraping")
        except:
            print("⚠ Selenium not available")
        
        try:
            from bs4 import BeautifulSoup
            self.bs4 = BeautifulSoup
            print("✓ BeautifulSoup ready")
        except:
            print("⚠ BeautifulSoup not available")
    
    def scrape_url(self, url: str) -> Optional[str]:
        """Scrape content from URL"""
        if not self.selenium or not self.bs4:
            return None
        
        try:
            options = self.selenium['Options']()
            options.add_argument('--headless')
            options.add_argument('--no-sandbox')
            options.add_argument('--disable-dev-shm-usage')
            options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
            
            driver = self.selenium['webdriver'].Chrome(options=options)
            driver.set_page_load_timeout(20)
            
            driver.get(url)
            
            # Wait for page load
            wait = self.selenium['WebDriverWait'](driver, 10)
            wait.until(self.selenium['EC'].presence_of_element_located(
                (self.selenium['By'].TAG_NAME, "body")
            ))
            
            # Get page source and parse
            page_source = driver.page_source
            driver.quit()
            
            soup = self.bs4(page_source, 'html.parser')
            
            # Remove scripts and styles
            for script in soup(["script", "style", "nav", "footer", "header"]):
                script.decompose()
            
            # Extract text
            text = soup.get_text(separator='\n', strip=True)
            
            # Clean up
            lines = [line.strip() for line in text.split('\n') if len(line.strip()) > 30]
            return '\n'.join(lines[:50])  # Limit to 50 lines
            
        except Exception as e:
            print(f"Web scraping error: {e}")
            return None

# =====================================================
# MAIN AI SYSTEM
# =====================================================
class AIConversationSystem:
    """Main AI conversation system"""
    
    def __init__(self):
        print("🚀 Initializing AI Conversation System...")
        
        # Initialize components
        self.nlp = TinyNLP()
        self.parser = DocumentParser()
        self.graph = KnowledgeGraph(self.nlp)
        self.conversation = ConversationEngine(self.nlp, self.graph)
        self.voice = VoiceInterface()
        self.web = WebIntegration()
        
        # Load knowledge
        if CONFIG['knowledge']['auto_load']:
            self.load_knowledge_base()
        
        print("✅ AI Conversation System ready!")
        print(f"   Knowledge: {len(self.graph.nodes)} nodes")
        print(f"   Vocabulary: {len(self.nlp.vocab)} words")
        print(f"   Voice: {'Enabled' if CONFIG['voice']['enabled'] else 'Disabled'}")
    
    def load_knowledge_base(self):
        """Load all documents from knowledge folder"""
        if not KNOWLEDGE_FOLDER.exists():
            print("⚠ Knowledge folder not found")
            return
        
        supported = CONFIG['knowledge']['supported_formats']
        files_loaded = 0
        
        for file_path in KNOWLEDGE_FOLDER.rglob('*'):
            if file_path.is_file() and file_path.suffix.lower() in supported:
                try:
                    content, metadata = self.parser.parse_file(file_path)
                    if content and metadata.get('parsed', False):
                        self.graph.add_document(content, str(file_path.name))
                        files_loaded += 1
                except Exception as e:
                    print(f"Error loading {file_path.name}: {e}")
        
        print(f"📚 Loaded {files_loaded} documents into knowledge graph")
        self.graph.save()
        self.nlp.save_model()
    
    def process_conversation(self, user_input: str, use_voice: bool = False) -> Dict[str, Any]:
        """Process user input and generate response"""
        
        # Analyze input
        analysis = self.conversation.analyze_input(user_input)
        
        # Get context from knowledge graph
        context = self.graph.search(user_input, top_k=2)
        context_text = " ".join([c['content'][:150] for c in context])
        
        # Generate response
        response = self.conversation.generate_response(user_input, analysis)
        
        # Check for topic change suggestion
        topic_change = self.conversation.suggest_topic_change()
        if topic_change and random.random() < 0.3:
            response += f"\n\nBy the way, {topic_change['content']}"
        
        # Add conversation to graph
        self.graph.add_conversation_turn(user_input, response)
        
        # Speak if voice enabled
        if use_voice and CONFIG['voice']['enabled']:
            self.voice.speak(response[:200])
        
        # Prepare result
        result = {
            "response": response,
            "analysis": analysis,
            "knowledge_used": len(context) > 0,
            "topics": [t[0] for t in analysis['topics'][:3]],
            "suggested_topic": topic_change['topic'] if topic_change else None,
            "conversation_pattern": self.graph.get_conversation_pattern()
        }
        
        return result
    
    def web_search_conversation(self, query: str) -> Optional[Dict]:
        """Search web for conversation material"""
        if not query or 'http' not in query:
            # Construct search URL
            search_query = query.replace(' ', '+')
            url = f"https://duckduckgo.com/html/?q={search_query}"
        else:
            url = query
        
        content = self.web.scrape_url(url)
        if content:
            # Add to knowledge graph
            self.graph.add_document(content, f"web:{url[:50]}")
            
            return {
                "source": url,
                "content_preview": content[:200] + "...",
                "added_to_knowledge": True
            }
        
        return None
    
    def get_system_stats(self) -> Dict[str, Any]:
        """Get system statistics"""
        return {
            "knowledge_nodes": len(self.graph.nodes),
            "conversation_turns": len(self.graph.conversation_history),
            "vocabulary_size": len(self.nlp.vocab),
            "topics_covered": len(self.graph.topics),
            "current_pattern": self.graph.get_conversation_pattern(),
            "emotion_state": self.conversation.emotion_state,
            "conversation_depth": self.conversation.conversation_depth
        }

# =====================================================
# WEB INTERFACE
# =====================================================
def create_web_interface(ai_system: AIConversationSystem):
    """Create modern web interface"""
    
    try:
        from flask import Flask, request, jsonify, render_template_string
    except ImportError:
        print("⚠ Flask not available, installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "flask"])
        from flask import Flask, request, jsonify, render_template_string
    
    app = Flask(__name__)
    
    HTML_TEMPLATE = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>AI Conversation Engine 2025</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            .fade-in { animation: fadeIn 0.3s; }
            .slide-up { animation: slideUp 0.3s; }
            .pulse { animation: pulse 2s infinite; }
            @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
            @keyframes slideUp { from { transform: translateY(10px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
            @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.7; } }
            .conversation-bg { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
            .glass { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.2); }
        </style>
    </head>
    <body class="conversation-bg min-h-screen p-4 md:p-8">
        <div class="max-w-6xl mx-auto">
            <!-- Header -->
            <div class="glass rounded-3xl p-6 mb-8 text-white">
                <div class="flex flex-col md:flex-row justify-between items-center">
                    <div class="mb-4 md:mb-0">
                        <h1 class="text-3xl md:text-4xl font-bold mb-2">🤖 AI Conversation Engine 2025</h1>
                        <p class="opacity-90">Endless human-like conversations • Tiny NLP • Multi-format • Voice I/O</p>
                    </div>
                    <div class="flex items-center space-x-4">
                        <div class="bg-green-500/30 px-4 py-2 rounded-full flex items-center">
                            <div class="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></div>
                            <span class="font-semibold">System Online</span>
                        </div>
                        <button onclick="voiceInput()" class="bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-full flex items-center">
                            <i class="fas fa-microphone mr-2"></i> Voice
                        </button>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
                <!-- Sidebar -->
                <div class="lg:col-span-1 space-y-6">
                    <!-- Stats -->
                    <div class="glass rounded-2xl p-6 text-white">
                        <h2 class="text-xl font-bold mb-4"><i class="fas fa-chart-bar mr-2"></i> Conversation Stats</h2>
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="opacity-80">Knowledge Nodes</span>
                                <span class="font-bold" id="node-count">0</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="opacity-80">Turns</span>
                                <span class="font-bold" id="turn-count">0</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="opacity-80">Current Depth</span>
                                <span class="font-bold" id="depth">1.0</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="opacity-80">Emotion</span>
                                <span class="font-bold" id="emotion">Neutral</span>
                            </div>
                        </div>
                    </div>

                    <!-- Topics -->
                    <div class="glass rounded-2xl p-6 text-white">
                        <h2 class="text-xl font-bold mb-4"><i class="fas fa-tags mr-2"></i> Active Topics</h2>
                        <div id="topics-list" class="flex flex-wrap gap-2">
                            <!-- Topics load here -->
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="glass rounded-2xl p-6 text-white">
                        <h2 class="text-xl font-bold mb-4"><i class="fas fa-bolt mr-2"></i> Quick Actions</h2>
                        <div class="space-y-3">
                            <button onclick="suggestTopic()" class="w-full bg-purple-500 hover:bg-purple-600 text-white py-3 rounded-xl flex items-center justify-center">
                                <i class="fas fa-lightbulb mr-2"></i> Suggest Topic
                            </button>
                            <button onclick="webSearch()" class="w-full bg-blue-500 hover:bg-blue-600 text-white py-3 rounded-xl flex items-center justify-center">
                                <i class="fas fa-globe mr-2"></i> Web Search
                            </button>
                            <button onclick="loadMoreDocs()" class="w-full bg-amber-500 hover:bg-amber-600 text-white py-3 rounded-xl flex items-center justify-center">
                                <i class="fas fa-sync mr-2"></i> Reload Docs
                            </button>
                            <button onclick="clearChat()" class="w-full bg-red-500 hover:bg-red-600 text-white py-3 rounded-xl flex items-center justify-center">
                                <i class="fas fa-trash mr-2"></i> Clear Chat
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Main Chat -->
                <div class="lg:col-span-3">
                    <div class="glass rounded-2xl p-6 h-[600px] flex flex-col">
                        <!-- Chat Messages -->
                        <div class="flex-1 overflow-y-auto mb-6 p-4 rounded-xl bg-white/5" id="chat-messages">
                            <div class="fade-in">
                                <div class="bg-blue-500/20 text-white rounded-2xl p-4 max-w-[85%] mb-4 ml-auto">
                                    <div class="font-semibold mb-1 text-sm opacity-80">System</div>
                                    <div>👋 Welcome! I'm your AI conversation partner. I can discuss anything from your knowledge base, explore new topics, and have endless natural conversations. Let's talk!</div>
                                </div>
                            </div>
                        </div>

                        <!-- Input Area -->
                        <div class="relative">
                            <div class="flex space-x-3">
                                <input type="text" id="user-input" 
                                       placeholder="Type your message here... (try: 'Tell me about AI' or 'Let's discuss science')" 
                                       class="flex-1 bg-white/10 border border-white/20 rounded-2xl px-5 py-4 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                       onkeypress="if(event.key === 'Enter') sendMessage()">
                                <button onclick="sendMessage()" class="bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white font-bold px-6 rounded-2xl transition flex items-center">
                                    <i class="fas fa-paper-plane mr-2"></i> Send
                                </button>
                            </div>
                            
                            <!-- Status -->
                            <div id="status" class="mt-3 hidden p-3 rounded-xl bg-amber-500/20 text-amber-300">
                                <i class="fas fa-spinner fa-spin mr-2"></i>
                                <span id="status-text">Processing...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="mt-8 text-center text-white/60 text-sm">
                <p>AI Conversation Engine 2025 • Tiny NLP • Endless Conversations • <span id="model-status">Model: Tiny Local</span></p>
            </div>
        </div>

        <script>
            let conversationHistory = [];
            
            function updateStats() {
                fetch('/api/stats')
                    .then(r => r.json())
                    .then(data => {
                        document.getElementById('node-count').textContent = data.knowledge_nodes;
                        document.getElementById('turn-count').textContent = data.conversation_turns;
                        document.getElementById('depth').textContent = data.conversation_depth.toFixed(1);
                        document.getElementById('emotion').textContent = data.emotion_state;
                        
                        // Update topics
                        const topicsDiv = document.getElementById('topics-list');
                        if (data.current_pattern && data.current_pattern.main_topic) {
                            topicsDiv.innerHTML = `
                                <span class="bg-white/20 px-3 py-1 rounded-full text-sm">${data.current_pattern.main_topic}</span>
                                <span class="bg-white/10 px-3 py-1 rounded-full text-sm">${data.current_pattern.pattern}</span>
                                <span class="bg-white/10 px-3 py-1 rounded-full text-sm">${data.current_pattern.depth}</span>
                            `;
                        }
                    });
            }
            
            function sendMessage() {
                const input = document.getElementById('user-input');
                const message = input.value.trim();
                if (!message) return;
                
                // Add user message
                addMessage(message, 'user');
                input.value = '';
                
                // Show status
                showStatus('🤔 Generating response...');
                
                // Send to AI
                fetch('/api/chat', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ 
                        message: message,
                        use_voice: false
                    })
                })
                .then(r => r.json())
                .then(data => {
                    hideStatus();
                    addMessage(data.response, 'ai', data);
                    updateStats();
                    
                    // Auto-scroll
                    const chatDiv = document.getElementById('chat-messages');
                    chatDiv.scrollTop = chatDiv.scrollHeight;
                })
                .catch(err => {
                    hideStatus();
                    showStatus('❌ Error: ' + err, 'error');
                });
            }
            
            function addMessage(text, sender, data = null) {
                const messagesDiv = document.getElementById('chat-messages');
                
                const messageDiv = document.createElement('div');
                messageDiv.className = `slide-up mb-4 ${sender === 'user' ? 'text-right' : ''}`;
                
                let html = '';
                if (sender === 'user') {
                    html = `
                        <div class="inline-block bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-2xl p-4 max-w-[85%]">
                            <div class="font-semibold mb-1 text-sm opacity-80">You</div>
                            <div>${text}</div>
                        </div>`;
                } else {
                    const topics = data?.topics || [];
                    
                    html = `
                        <div class="bg-white/10 text-white rounded-2xl p-4 max-w-[85%]">
                            <div class="flex justify-between items-center mb-2">
                                <div class="font-semibold">AI Assistant</div>
                                ${data?.suggested_topic ? `
                                    <div class="text-xs bg-purple-500/30 px-2 py-1 rounded">
                                        <i class="fas fa-lightbulb mr-1"></i> ${data.suggested_topic}
                                    </div>
                                ` : ''}
                            </div>
                            <div class="mb-3">${text.replace(/\n/g, '<br>')}</div>
                            ${topics.length ? `
                                <div class="text-xs opacity-80 mt-2">
                                    <i class="fas fa-tags mr-1"></i>
                                    ${topics.map(t => `<span class="bg-white/10 px-2 py-1 rounded mr-1">${t}</span>`).join('')}
                                </div>
                            ` : ''}
                        </div>`;
                }
                
                messageDiv.innerHTML = html;
                messagesDiv.appendChild(messageDiv);
                
                // Store in history
                conversationHistory.push({text, sender, time: new Date().toISOString()});
            }
            
            function voiceInput() {
                showStatus('🎤 Listening... Speak now');
                
                fetch('/api/voice')
                    .then(r => r.json())
                    .then(data => {
                        hideStatus();
                        if (data.text) {
                            document.getElementById('user-input').value = data.text;
                        } else {
                            showStatus('Could not understand voice input', 'error');
                            setTimeout(hideStatus, 2000);
                        }
                    });
            }
            
            function suggestTopic() {
                fetch('/api/suggest-topic')
                    .then(r => r.json())
                    .then(data => {
                        if (data.topic) {
                            document.getElementById('user-input').value = `Let's discuss ${data.topic}`;
                        }
                    });
            }
            
            function webSearch() {
                const query = prompt('Enter search query or URL:');
                if (query) {
                    showStatus('🌐 Searching web...');
                    fetch('/api/web-search', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({ query: query })
                    })
                    .then(r => r.json())
                    .then(data => {
                        hideStatus();
                        if (data.content_preview) {
                            addMessage(`I found this information: ${data.content_preview}`, 'ai');
                        }
                    });
                }
            }
            
            function loadMoreDocs() {
                showStatus('📚 Reloading documents...');
                fetch('/api/reload-docs')
                    .then(r => r.json())
                    .then(data => {
                        hideStatus();
                        showStatus(`✅ Loaded ${data.loaded} documents`, 'success');
                        setTimeout(hideStatus, 2000);
                        updateStats();
                    });
            }
            
            function clearChat() {
                if (confirm('Clear conversation history?')) {
                    document.getElementById('chat-messages').innerHTML = `
                        <div class="fade-in">
                            <div class="bg-blue-500/20 text-white rounded-2xl p-4 max-w-[85%] mb-4 ml-auto">
                                <div class="font-semibold mb-1 text-sm opacity-80">System</div>
                                <div>Conversation cleared. Ready for new discussion!</div>
                            </div>
                        </div>`;
                    conversationHistory = [];
                }
            }
            
            function showStatus(text, type = 'info') {
                const statusDiv = document.getElementById('status');
                const statusText = document.getElementById('status-text');
                statusText.textContent = text;
                
                statusDiv.className = 'mt-3 p-3 rounded-xl ';
                if (type === 'error') {
                    statusDiv.className += 'bg-red-500/20 text-red-300';
                } else if (type === 'success') {
                    statusDiv.className += 'bg-green-500/20 text-green-300';
                } else {
                    statusDiv.className += 'bg-amber-500/20 text-amber-300';
                }
                
                statusDiv.classList.remove('hidden');
            }
            
            function hideStatus() {
                document.getElementById('status').classList.add('hidden');
            }
            
            // Initialize
            updateStats();
            setInterval(updateStats, 5000);
            
            // Auto-focus input
            document.getElementById('user-input').focus();
        </script>
    </body>
    </html>
    '''
    
    @app.route('/')
    def home():
        return render_template_string(HTML_TEMPLATE)
    
    @app.route('/api/chat', methods=['POST'])
    def api_chat():
        data = request.json
        message = data.get('message', '').strip()
        use_voice = data.get('use_voice', False)
        
        if not message:
            return jsonify({'error': 'No message provided'})
        
        try:
            result = ai_system.process_conversation(message, use_voice=use_voice)
            return jsonify(result)
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/stats', methods=['GET'])
    def api_stats():
        try:
            stats = ai_system.get_system_stats()
            return jsonify(stats)
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/voice', methods=['GET'])
    def api_voice():
        try:
            text = ai_system.voice.listen()
            return jsonify({'text': text or ''})
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/suggest-topic', methods=['GET'])
    def api_suggest_topic():
        try:
            pattern = ai_system.graph.get_conversation_pattern()
            current_topic = pattern.get('main_topic')
            suggestion = ai_system.graph.suggest_conversation_topic(current_topic)
            return jsonify(suggestion or {'topic': 'artificial intelligence'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/web-search', methods=['POST'])
    def api_web_search():
        data = request.json
        query = data.get('query', '').strip()
        
        if not query:
            return jsonify({'error': 'No query provided'})
        
        try:
            result = ai_system.web_search_conversation(query)
            return jsonify(result or {'error': 'Web search failed'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/reload-docs', methods=['GET'])
    def api_reload_docs():
        try:
            ai_system.load_knowledge_base()
            return jsonify({'loaded': len(ai_system.graph.nodes)})
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return app

# =====================================================
# MAIN EXECUTION
# =====================================================
def main():
    print("\n" + "="*70)
    print("🤖 AI CONVERSATION ENGINE 2025")
    print("="*70)
    print("Features:")
    print("  • Tiny NLP Model (Fast & Local)")
    print("  • Endless Human-like Conversations")
    print("  • Multi-format Document Parsing (PDF, DOCX, Excel, Images)")
    print("  • Voice Input/Output")
    print("  • Web Integration (Selenium + BeautifulSoup)")
    print("  • Semantic Knowledge Graph")
    print("="*70)
    
    # Check for required packages
    print("\n📦 Checking/installing required packages...")
    import subprocess
    import sys
    
    packages = [
        "flask",
        "PyPDF2",
        "pandas",
        "python-docx",
        "Pillow",
        "pytesseract",
        "pyttsx3",
        "SpeechRecognition",
        "selenium",
        "beautifulsoup4",
        "numpy",
        "waitress"
    ]
    
    for pkg in packages:
        try:
            __import__(pkg.replace('-', '_'))
            print(f"  ✓ {pkg}")
        except ImportError:
            print(f"  ⚠ Installing {pkg}...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", pkg, "--quiet"])
    
    # Create and run AI system
    ai_system = AIConversationSystem()
    
    print("\n" + "="*70)
    print("✅ SYSTEM READY!")
    print("="*70)
    print(f"📁 Knowledge Folder: {KNOWLEDGE_FOLDER}")
    print(f"💾 Memory: {len(ai_system.graph.nodes)} knowledge nodes")
    print(f"🎤 Voice: {'Enabled' if CONFIG['voice']['enabled'] else 'Disabled'}")
    print(f"🌐 Web Interface: http://localhost:8080")
    print("="*70)
    print("\n💡 Usage Tips:")
    print("  • Add documents to 'knowledge' folder for conversation material")
    print("  • Use voice button for hands-free interaction")
    print("  • Conversation evolves naturally based on patterns")
    print("  • System learns and improves over time")
    print("\nStarting web server...\n")
    
    # Create and run web server
    app = create_web_interface(ai_system)
    
    # Use waitress for production
    try:
        from waitress import serve
        serve(app, host='0.0.0.0', port=8080)
    except:
        app.run(host='0.0.0.0', port=8080, debug=False)

if __name__ == "__main__":
    main()
'@

# Save the Python file
$aiCode | Out-File -FilePath "$AI_DIR\ai_conversation.py" -Encoding UTF8
Write-Host "  ✓ Created AI Conversation Engine: ai_conversation.py" -ForegroundColor Green

# =====================================================
# CREATE EXAMPLE KNOWLEDGE FILES
# =====================================================
Write-Host "[2/5] 📚 Creating example knowledge base..." -ForegroundColor Green

# Create AI conversation knowledge
@'
# Artificial Intelligence Conversations

## Starting Points for AI Discussions:
1. "What are the ethical implications of advanced AI systems?"
2. "How might AI transform education in the next decade?"
3. "What makes human intelligence different from artificial intelligence?"
4. "Can AI truly be creative, or is it just pattern recognition?"
5. "What are the risks and benefits of AI in healthcare?"

## Conversation Techniques:
- Ask open-ended questions
- Build on previous points
- Connect ideas across domains
- Explore hypothetical scenarios
- Balance facts with philosophical inquiry

## Interesting AI Topics:
- Neural networks and deep learning
- Natural language processing advances
- Computer vision applications
- Robotics and automation
- AI in scientific discovery
- Ethical AI development
- Future of human-AI collaboration
- AI safety and alignment
- Economic impacts of AI
- AI in creative arts

## Deep Conversation Prompts:
"What if we could create an AI that truly understands human emotions? How would that change society?"
"Should there be limits on AI development, and if so, who should set them?"
"How do we ensure AI benefits all of humanity, not just a privileged few?"
"What does consciousness mean in the context of AI?"
"How might AI help us solve complex global problems like climate change?"
'@ | Out-File -FilePath "$KNOWLEDGE_FOLDER\ai_conversations.txt" -Encoding UTF8

# Create science knowledge
@'
# Science Discussion Topics

## Physics Conversations:
- Quantum mechanics and its interpretations
- The nature of time and space
- Dark matter and dark energy mysteries
- The Standard Model and beyond
- Theory of everything possibilities

## Biology Discussions:
- Genetics and CRISPR technology
- Evolution and natural selection
- Neuroscience and consciousness
- Ecology and climate change
- Origin of life questions

## Chemistry Topics:
- Chemical reactions and energy
- Material science advances
- Biochemistry and medicine
- Environmental chemistry
- Nanotechnology applications

## Earth Science:
- Climate change evidence
- Geological processes
- Oceanography discoveries
- Atmospheric science
- Natural disasters prediction

## Astronomy Conversations:
- Exoplanets and life possibilities
- Black holes and singularities
- The expanding universe
- Cosmic background radiation
- Future of space exploration

## Cross-disciplinary Questions:
"How does quantum physics relate to consciousness?"
"What can biochemistry teach us about the origin of life?"
"How might climate change solutions come from multiple scientific fields?"
"What are the ethical boundaries of genetic engineering?"
"How does our understanding of the universe affect human philosophy?"
'@ | Out-File -FilePath "$KNOWLEDGE_FOLDER\science_discussions.txt" -Encoding UTF8

# Create philosophy knowledge
@'
# Philosophical Conversations

## Ethics and Morality:
- Utilitarianism vs deontology
- Moral relativism debates
- Ethical implications of technology
- Animal rights and environmental ethics
- Justice and fairness theories

## Epistemology (Knowledge):
- Nature of truth and belief
- Rationalism vs empiricism
- Limits of human understanding
- Scientific method as epistemology
- Artificial intelligence and knowledge

## Metaphysics (Reality):
- Nature of consciousness
- Free will vs determinism
- Mind-body problem
- Nature of time
- Existence and being

## Logic and Reasoning:
- Deductive vs inductive reasoning
- Logical fallacies to avoid
- Critical thinking techniques
- Argument analysis
- Problem-solving approaches

## Existential Questions:
"What gives life meaning and purpose?"
"How should we face mortality?"
"What is the nature of happiness?"
"How do we define success?"
"What is the relationship between individual and society?"

## Conversation Techniques:
- Socratic questioning
- Thought experiments
- Exploring assumptions
- Considering counterarguments
- Synthesizing different viewpoints

## Modern Philosophical Issues:
- Ethics of artificial intelligence
- Privacy in digital age
- Environmental responsibility
- Global justice and inequality
- Future of human enhancement
'@ | Out-File -FilePath "$KNOWLEDGE_FOLDER\philosophy.txt" -Encoding UTF8

Write-Host "  ✓ Created 3 conversation knowledge files" -ForegroundColor Green

# =====================================================
# CREATE LAUNCHER SCRIPTS
# =====================================================
Write-Host "[3/5] 🚀 Creating launchers..." -ForegroundColor Green

# PowerShell launcher
$psLauncher = @'
# AI Conversation Engine Launcher
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                 AI CONVERSATION ENGINE 2025                             ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "🔍 Checking Python..." -ForegroundColor Yellow
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found!" -ForegroundColor Red
    Write-Host "📥 Download from: https://python.org" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Python found" -ForegroundColor Green

# Install packages
Write-Host ""
Write-Host "📦 Installing packages (this will take a few minutes)..." -ForegroundColor Yellow

$packages = @(
    "flask",
    "PyPDF2",
    "pandas",
    "openpyxl",
    "python-docx",
    "Pillow",
    "pytesseract",
    "pyttsx3",
    "SpeechRecognition",
    "selenium",
    "beautifulsoup4",
    "numpy",
    "waitress"
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..." -NoNewline
    try {
        python -m pip install $pkg --quiet 2>$null
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Packages installed!" -ForegroundColor Green

# Start AI
Write-Host ""
Write-Host "🚀 Starting AI Conversation Engine..." -ForegroundColor Green
Write-Host ""
Write-Host "📁 Knowledge Folder: $PSScriptRoot\knowledge" -ForegroundColor Cyan
Write-Host "🎤 Voice Interface: Ready" -ForegroundColor Cyan
Write-Host "🤖 Tiny NLP Model: Loaded" -ForegroundColor Cyan
Write-Host "🌐 Web Interface: http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Features:" -ForegroundColor Yellow
Write-Host "  • Endless human-like conversations" -ForegroundColor White
Write-Host "  • PDF/DOCX/Excel/Image parsing" -ForegroundColor White
Write-Host "  • Voice input/output" -ForegroundColor White
Write-Host "  • Web integration" -ForegroundColor White
Write-Host "  • Learning and memory" -ForegroundColor White
Write-Host ""
Write-Host "💡 Add your documents to the 'knowledge' folder" -ForegroundColor Cyan
Write-Host ""

# Start the AI
Start-Process python -ArgumentList "ai_conversation.py" -NoNewWindow

# Wait and open browser
Start-Sleep 5
try {
    Start-Process "http://localhost:8080"
    Write-Host "✅ Browser opened!" -ForegroundColor Green
} catch {
    Write-Host "⚠ Please open: http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🤖 AI is now running! Start chatting!" -ForegroundColor Green
Write-Host "🎤 Voice commands available" -ForegroundColor Cyan
Write-Host "💬 Endless conversation mode active" -ForegroundColor Cyan
Write-Host ""
Write-Host "🛑 Press Ctrl+C in Python window to stop" -ForegroundColor Gray
Write-Host ""
'@
$psLauncher | Out-File -FilePath "$AI_DIR\Start-Conversation.ps1" -Encoding UTF8
Write-Host "  ✓ Created Start-Conversation.ps1" -ForegroundColor Green

# Batch launcher
$batchLauncher = @'
@echo off
chcp 65001 >nul
echo.
echo ========================================
echo     AI CONVERSATION ENGINE 2025
echo ========================================
echo.
echo Installing packages...
python -m pip install flask PyPDF2 pandas python-docx Pillow pytesseract pyttsx3 SpeechRecognition selenium beautifulsoup4 numpy waitress --quiet
echo.
echo Starting AI system...
echo.
echo Features:
echo   • Endless human conversations
echo   • Multi-format document parsing
echo   • Voice interface
echo   • Web integration
echo   • Tiny NLP model
echo.
echo Open: http://localhost:8080
echo.
python ai_conversation.py
pause
'@
$batchLauncher | Out-File -FilePath "$AI_DIR\Start-AI.bat" -Encoding ASCII
Write-Host "  ✓ Created Start-AI.bat" -ForegroundColor Green

# =====================================================
# CREATE C++ SIMILARITY DLL (OPTIONAL)
# =====================================================
Write-Host "[4/5] ⚡ Creating C++ similarity engine..." -ForegroundColor Green

$cppCode = @'
// sim_engine.cpp - Fast similarity calculation
#include <windows.h>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <unordered_map>
#include <numeric>

extern "C" {
    __declspec(dllexport) double similarity(const char* text1, const char* text2);
    __declspec(dllexport) double similarity_vector(const double* vec1, const double* vec2, int size);
}

// Simple text processing
std::vector<std::string> split_words(const std::string& text) {
    std::vector<std::string> words;
    std::string current;
    
    for (char c : text) {
        if (std::isalpha(c)) {
            current += std::tolower(c);
        } else if (!current.empty()) {
            if (current.length() > 2) {
                words.push_back(current);
            }
            current.clear();
        }
    }
    
    if (!current.empty() && current.length() > 2) {
        words.push_back(current);
    }
    
    return words;
}

// Calculate cosine similarity
double cosine_similarity(const std::unordered_map<std::string, double>& vec1,
                        const std::unordered_map<std::string, double>& vec2) {
    double dot = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (const auto& pair : vec1) {
        auto it = vec2.find(pair.first);
        if (it != vec2.end()) {
            dot += pair.second * it->second;
        }
        norm1 += pair.second * pair.second;
    }
    
    for (const auto& pair : vec2) {
        norm2 += pair.second * pair.second;
    }
    
    if (norm1 == 0.0 || norm2 == 0.0) {
        return 0.0;
    }
    
    return dot / (std::sqrt(norm1) * std::sqrt(norm2));
}

// Main similarity function
__declspec(dllexport) double similarity(const char* text1, const char* text2) {
    std::string str1(text1);
    std::string str2(text2);
    
    // Convert to lowercase
    std::transform(str1.begin(), str1.end(), str1.begin(), ::tolower);
    std::transform(str2.begin(), str2.end(), str2.begin(), ::tolower);
    
    // Split into words
    auto words1 = split_words(str1);
    auto words2 = split_words(str2);
    
    if (words1.empty() || words2.empty()) {
        return 0.0;
    }
    
    // Count word frequencies
    std::unordered_map<std::string, double> freq1, freq2;
    
    for (const auto& word : words1) {
        freq1[word] += 1.0;
    }
    
    for (const auto& word : words2) {
        freq2[word] += 1.0;
    }
    
    // Normalize frequencies
    double sum1 = 0.0, sum2 = 0.0;
    for (auto& pair : freq1) sum1 += pair.second;
    for (auto& pair : freq2) sum2 += pair.second;
    
    if (sum1 > 0.0) {
        for (auto& pair : freq1) pair.second /= sum1;
    }
    
    if (sum2 > 0.0) {
        for (auto& pair : freq2) pair.second /= sum2;
    }
    
    // Calculate similarity
    return cosine_similarity(freq1, freq2);
}

// Vector similarity function
__declspec(dllexport) double similarity_vector(const double* vec1, const double* vec2, int size) {
    double dot = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (int i = 0; i < size; ++i) {
        dot += vec1[i] * vec2[i];
        norm1 += vec1[i] * vec1[i];
        norm2 += vec2[i] * vec2[i];
    }
    
    if (norm1 == 0.0 || norm2 == 0.0) {
        return 0.0;
    }
    
    return dot / (std::sqrt(norm1) * std::sqrt(norm2));
}

// DLL entry point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    return TRUE;
}
'@
$cppCode | Out-File -FilePath "$AI_DIR\sim_engine.cpp" -Encoding UTF8
Write-Host "  ✓ Created C++ similarity engine source" -ForegroundColor Green

# Create compile script
$compileScript = @'
# Compile C++ similarity engine
Write-Host "Compiling C++ similarity engine..." -ForegroundColor Yellow

# Try different compilers
$compilers = @("g++", "cl.exe", "clang++")

foreach ($compiler in $compilers) {
    if (Get-Command $compiler -ErrorAction SilentlyContinue) {
        Write-Host "Found compiler: $compiler" -ForegroundColor Green
        
        if ($compiler -eq "cl.exe") {
            # MSVC
            cl.exe /LD /Fesim_engine.dll sim_engine.cpp /link /DLL
        } else {
            # g++ or clang++
            & $compiler -shared -o sim_engine.dll sim_engine.cpp -std=c++11
        }
        
        if (Test-Path "sim_engine.dll") {
            Write-Host "✅ C++ similarity engine compiled successfully!" -ForegroundColor Green
            break
        }
    }
}

if (-not (Test-Path "sim_engine.dll")) {
    Write-Host "⚠ Could not compile C++ engine. Using Python fallback." -ForegroundColor Yellow
}
'@
$compileScript | Out-File -FilePath "$AI_DIR\compile_cpp.ps1" -Encoding UTF8
Write-Host "  ✓ Created C++ compile script" -ForegroundColor Green

# =====================================================
# CREATE BUILD EXE SCRIPT
# =====================================================
Write-Host "[5/5] 🏗 Creating EXE builder..." -ForegroundColor Green

$exeBuilder = @'
# Build EXE version
Write-Host "Building standalone EXE..." -ForegroundColor Yellow

# Install PyInstaller
python -m pip install pyinstaller --quiet

# Create entry point
@"
import sys
sys.path.insert(0, r'$PSScriptRoot')
from ai_conversation import main

if __name__ == '__main__':
    main()
"@ | Out-File -FilePath "exe_entry.py" -Encoding UTF8

# Build with PyInstaller
$pyinstallerArgs = @(
    "--onefile",
    "--name=AI_Conversation_Engine",
    "--add-data=knowledge;knowledge",
    "--add-data=models;models",
    "--hidden-import=flask",
    "--hidden-import=PyPDF2",
    "--hidden-import=pandas",
    "--hidden-import=docx",
    "--hidden-import=PIL",
    "--hidden-import=pytesseract",
    "--hidden-import=pyttsx3",
    "--hidden-import=speech_recognition",
    "--hidden-import=selenium",
    "--hidden-import=bs4",
    "--hidden-import=numpy",
    "--clean",
    "exe_entry.py"
)

pyinstaller $pyinstallerArgs

if (Test-Path "dist\AI_Conversation_Engine.exe") {
    Copy-Item "dist\AI_Conversation_Engine.exe" -Destination "AI_Conversation_Engine.exe" -Force
    Write-Host "✅ EXE created: AI_Conversation_Engine.exe" -ForegroundColor Green
    Write-Host "   Size: $((Get-Item 'AI_Conversation_Engine.exe').Length / 1MB) MB" -ForegroundColor Cyan
} else {
    Write-Host "❌ EXE creation failed" -ForegroundColor Red
}
'@
$exeBuilder | Out-File -FilePath "$AI_DIR\Build-EXE.ps1" -Encoding UTF8
Write-Host "  ✓ Created EXE builder" -ForegroundColor Green

# =====================================================
# CREATE README
# =====================================================
$readme = @'
# AI CONVERSATION ENGINE 2025

## 🚀 ONE-CLICK SETUP

### Option 1: PowerShell (Recommended)
```powershell
.\Start-Conversation.ps1