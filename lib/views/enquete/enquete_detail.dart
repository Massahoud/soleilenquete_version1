import 'package:flutter/material.dart';
import 'package:soleilenquete/services/enquete_service.dart';
import 'package:soleilenquete/services/chat_service.dart';
import 'package:soleilenquete/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 

class EnqueteDetailPage extends StatefulWidget {
  final String enqueteId;

  const EnqueteDetailPage({Key? key, required this.enqueteId}) : super(key: key);

  @override
  State<EnqueteDetailPage> createState() => _EnqueteDetailPageState();
}

class _EnqueteDetailPageState extends State<EnqueteDetailPage> {
  final EnqueteService enqueteService = EnqueteService();
  final ChatService chatService = ChatService();
  Map<String, dynamic>? enquete;
  List<dynamic> reponses = [];
  List<ChatMessage> messages = [];
  bool isLoading = true;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDetails();
    fetchChatMessages();
  }

  Future<void> fetchDetails() async {
    try {
      final enqueteData =
          await enqueteService.fetchEnqueteById(widget.enqueteId);
      final reponsesData =
          await enqueteService.fetchReponsesByEnqueteId(widget.enqueteId);

      setState(() {
        enquete = enqueteData;
        reponses = reponsesData;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${error.toString()}')),
      );
    }
  }

  Future<void> fetchChatMessages() async {
    try {
      final chatMessages =
          await chatService.getMessagesByEnqueteId(widget.enqueteId);
      setState(() {
        messages = chatMessages;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des messages : $error')),
      );
    }
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur : ID utilisateur introuvable. Veuillez vous reconnecter.'),
          ),
        );
        return;
      }

   
      final newMessage = await chatService.createMessage(
        enqueteId: widget.enqueteId,
        userId: userId,
        text: text,
      );

      
      setState(() {
        messages.add(newMessage);
      });

      _messageController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message : $error')),
      );
    }
  }

  
  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'enquête'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : enquete == null
              ? const Center(child: Text('Aucune donnée trouvée.'))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${enquete!['prenom_enfant']} ${enquete!['nom_enfant']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Âge: ${enquete!['age_enfant']}'),
                            Text('Sexe: ${enquete!['sexe_enfant']}'),
                            Text('Numéro: ${enquete!['numero']}'),
                          ],
                        ),
                      ),
                    ),

                    
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Réponses associées :',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: reponses.length,
                                itemBuilder: (context, index) {
                                  final reponse = reponses[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Numéro: ${reponse['numero']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Question: ${reponse['question_text']}',
                                            style: const TextStyle(
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Réponse: ${reponse['reponse_text']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: ListTile(
                                      title: Text(
                                        message.text,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        'Envoyé par: ${message.userId} - ${formatDate(message.date)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Entrez un message',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: sendMessage,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
