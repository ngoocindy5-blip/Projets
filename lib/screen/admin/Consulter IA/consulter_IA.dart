import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String GEMINI_API_KEY = "AIzaSyCOJNS2gA9FoUZ47epnfEeRxqjRZnwNW10"; // ⚠️ Mets ta vraie clé ici

class ConsulterIAView extends StatefulWidget {
  const ConsulterIAView({super.key});

  @override
  State<ConsulterIAView> createState() => _ConsulterIAViewState();
}

class _ConsulterIAViewState extends State<ConsulterIAView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "anonyme";

    setState(() {
      _messages.add({"role": "user", "content": text});
      _controller.clear();
      _loading = true;
    });

    // Sauvegarder la question dans Firestore
    await FirebaseFirestore.instance.collection("ia_consultations").add({
      "role": "user",
      "content": text,
      "createdAt": FieldValue.serverTimestamp(),
      "adminId": uid,
    });

    try {
      final model = GenerativeModel(
        model: "gemini-1.5-flash", // ✅ modèle valide
        apiKey: "AIzaSyCOJNS2gA9FoUZ47epnfEeRxqjRZnwNW10",
      );

      final response = await model.generateContent([Content.text(text)]);
      final reply = response.text ?? "Aucune réponse.";

      setState(() {
        _messages.add({"role": "ai", "content": reply});
      });

      // Sauvegarder la réponse dans Firestore
      await FirebaseFirestore.instance.collection("ia_consultations").add({
        "role": "ai",
        "content": reply,
        "createdAt": FieldValue.serverTimestamp(),
        "adminId": uid,
      });
    } catch (e) {
      final errorMsg = "Erreur : $e";
      setState(() {
        _messages.add({"role": "ai", "content": errorMsg});
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulter l’IA"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["content"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Posez une question à l’IA...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
