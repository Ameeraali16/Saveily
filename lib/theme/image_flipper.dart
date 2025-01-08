import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saveily_2/theme/color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageFlipper extends StatefulWidget {
  @override
  _ImageFlipperState createState() => _ImageFlipperState();
}

class _ImageFlipperState extends State<ImageFlipper> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  // List of image assets
  final List<String> images = [
    'lib/assets/Save.png',
    'lib/assets/Track.png',
    'lib/assets/Manage.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Schedule the timer after the widget is built to ensure the PageController is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(Duration(seconds: 5), _autoFlipImage);
    });
  }

  void _autoFlipImage(Timer timer) {
    if (_pageController.hasClients) {
      // Increment the page and loop back to the first page if we reach the last one
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // Animate to the new page
      _pageController.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _onDotClicked(int index) {
    if (_timer.isActive) {
      _timer.cancel(); // Cancel the timer temporarily
    }
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Restart the timer to resume automatic flipping
    _timer = Timer.periodic(Duration(seconds: 3), _autoFlipImage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250, // Fixed height to see if this helps with rendering
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                // Use Image.asset for local images
                return Image.asset(images[index]);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: images.length,
            effect: ScrollingDotsEffect(
              dotWidth: 10.0,
              dotHeight: 10.0,
              activeDotColor: primaryColor,
              dotColor: Colors.grey,
            ),
            onDotClicked: _onDotClicked, // Trigger page flip on dot click
          ),
        ],
      ),
    );
  }
}
