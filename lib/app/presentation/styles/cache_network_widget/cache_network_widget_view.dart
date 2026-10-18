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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/styles/cache_network_widget/bloc/cache_network_widget_bloc.dart';

class CacheNetworkImageWidget extends StatelessWidget {
  final double width;
  final double height;
  final String imageUrl;
  final BoxFit fit;
  const CacheNetworkImageWidget({super.key, required this.width, required this.height, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CacheNetworkWidgetBloc()..add(CachedNetworkImageInitialEvent()),
      child: CacheNetworkWidgetViewer(width: width, height: height, imageUrl: imageUrl, fit: fit),
    );
  }
}

class CacheNetworkWidgetViewer extends StatelessWidget {
  final double width;
  final double height;
  final String imageUrl;
  final BoxFit fit;
  const CacheNetworkWidgetViewer({super.key, required this.width, required this.height, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CacheNetworkWidgetBloc, CacheNetworkWidgetState>(
      listener: (context, state) {},
      builder: (context, state) {
        return CachedNetworkImage(
          height: height,
          width: width,
          imageUrl: '${state.mediaUrl}$imageUrl',
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: fit),
            ),
          ),
          placeholder: (context, url) => Image.asset(AssetsUrl.imageURL.placeholderImage, fit: fit, height: height, width: width),
          errorWidget: (context, url, error) => Image.asset(AssetsUrl.imageURL.placeholderImage, fit: fit, height: height, width: width),
        );
      },
    );
  }
}