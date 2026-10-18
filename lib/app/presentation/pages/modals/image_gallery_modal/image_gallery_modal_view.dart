/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:flutter/material.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/services/image_zoom_helper/image_widget_zoom.dart';

class ImageGalleryModalScreen extends StatelessWidget {
  final String name;
  final List<String> photos;
  const ImageGalleryModalScreen({super.key, required this.name, required this.photos});

  @override
  Widget build(BuildContext context) {
    return ImageGalleryModalView(name: name, photos: photos);
  }
}

class ImageGalleryModalView extends StatefulWidget {
  final String name;
  final List<String> photos;
  const ImageGalleryModalView({super.key, required this.name, required this.photos});

  @override
  State<ImageGalleryModalView> createState() => _ImageGalleryModalViewState();
}

class _ImageGalleryModalViewState extends State<ImageGalleryModalView> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 1);
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: PageView.builder(
        itemCount: widget.photos.length,
        scrollDirection: Axis.horizontal,
        controller: pageController,
        onPageChanged: (pageIndex) {
          setState(() {
            currentPageIndex = pageIndex;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              WidgetZoom(
                heroAnimationTag: widget.photos[index],
                zoomWidget: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 1.2, height: MediaQuery.of(context).size.height * 0.55, imageUrl: widget.photos[index], fit: BoxFit.contain),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(color: ThemeProvider.gradientBlackColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (currentPageIndex != 0) {
                            pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
                          }
                        },
                        child: const Icon(Icons.chevron_left, color: ThemeProvider.whiteColor, size: 25),
                      ),
                      kAppSpacerHorizontal(width: 10),
                      Text(
                        '${(currentPageIndex) + 1} / ${widget.photos.length}',
                        style: const TextStyle(color: ThemeProvider.whiteColor, fontFamily: 'regular', fontSize: 18),
                      ),
                      kAppSpacerHorizontal(width: 10),
                      GestureDetector(
                        onTap: () {
                          if ((currentPageIndex + 1) < widget.photos.length) {
                            pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
                          }
                        },
                        child: const Icon(Icons.chevron_right, color: ThemeProvider.whiteColor, size: 25),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// Done //
