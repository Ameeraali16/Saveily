import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
         
          const Text(
            "Privacy Policy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "This is the privacy policy, outlining how your data is used and protected.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class TermsOfUse extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Terms of Use",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Here are the terms of use of the app. Make sure to read all the information carefully before using the app.",
            style: TextStyle(fontSize: 14),
          ),
        const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ],
      ),
    );
  
}}




class BottomLinks extends StatelessWidget {
  const BottomLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return TermsOfUse(); // Replace with your actual widget
                },
              );
            },
            child: const Text(
              'Terms Of Use',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey, // Replace `TextColor` with an actual color
              ),
            ),
          ),
          const Text(
            '|',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey, // Replace `TextColor` with an actual color
            ),
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return PrivacyPolicy(); // Replace with your actual widget
                },
              );
            },
            child: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey, // Replace `TextColor` with an actual color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
