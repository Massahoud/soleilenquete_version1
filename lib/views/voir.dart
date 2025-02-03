import 'package:flutter/material.dart';

class SurveysPage extends StatelessWidget {
  const SurveysPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FFFF), // Background color
      appBar: AppBar(
        title: const Text('Mes enquêtes'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your profile image
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '816 ENQUÊTES',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher un N° d’enquête, Nom, Prénom, ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Vue en nuage de point'),
                      onSelected: (bool value) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Par période'),
                      onSelected: (bool value) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Par score'),
                      onSelected: (bool value) {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with your data count
                itemBuilder: (context, index) {
                  return SurveyCard(
                    surveyNumber: '00001',
                    date: '14 Sept 2024',
                    childName: 'Ouedraogo\nWendlasida Christian Abdoul',
                    city: 'Kongoussi',
                    age: '6 ans',
                    gender: '♂', // Gender symbol
                    status: index % 3 == 0
                        ? 'Nouveau'
                        : index % 3 == 1
                            ? 'En cours'
                            : 'Clôturé',
                    lastModifiedBy: index % 3 == 0 ? null : 'David Demange',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: const NavigationDrawer(), // Implement navigation drawer if needed
    );
  }
}

class SurveyCard extends StatelessWidget {
  final String surveyNumber;
  final String date;
  final String childName;
  final String city;
  final String age;
  final String gender;
  final String status;
  final String? lastModifiedBy;

  const SurveyCard({
    Key? key,
    required this.surveyNumber,
    required this.date,
    required this.childName,
    required this.city,
    required this.age,
    required this.gender,
    required this.status,
    this.lastModifiedBy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Nouveau':
        statusColor = Colors.orange;
        break;
      case 'En cours':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/child.jpg'), // Replace with child image
        ),
        title: Text(
          'Enquête $surveyNumber\n$date',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(childName),
            Text('$city / $gender / $age'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (lastModifiedBy != null)
              Text(
                '14 Sept 2024\n$lastModifiedBy',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        onTap: () {
          // Handle card tap
        },
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Le Soleil dans la Main - ONG',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Mes enquêtes'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Les utilisateurs'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Les Groupes d'utilisateurs"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Le questionnaire'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon profil'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
