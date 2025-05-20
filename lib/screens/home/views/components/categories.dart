import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

// For preview
class CategoryModel {
  final String name;
  final String? svgSrc, route;

  CategoryModel({
    required this.name,
    this.svgSrc,
    this.route,
  });
}

List<CategoryModel> demoCategories = [
  CategoryModel(name: "All Categories"),
  CategoryModel(
      name: "On Sale",
      svgSrc: "assets/icons/Sale.svg",
      route: onSaleScreenRoute),
  CategoryModel(name: "Souvenier's", svgSrc: "assets/icons/Man.svg"),
  CategoryModel(name: "Uniforms", svgSrc: "assets/icons/Woman.svg"),
  CategoryModel(
      name: "Essentials", svgSrc: "assets/icons/Child.svg", route: kidsScreenRoute),
];
// End For Preview

const List<String> kCategories = ['Souvenirs', 'Uniforms', 'Essentials'];
const List<IconData> kCategoryIcons = [
  Icons.card_giftcard, // Souvenirs
  Icons.checkroom,     // Uniforms
  Icons.book,          // Essentials
];

class Categories extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final List<String> categories;
  final List<IconData> icons;

  const Categories({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.categories,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;
    final isLarge = screenWidth > 700;

    final double chipHeight = isSmall ? 40 : isLarge ? 60 : 50;
    final double iconSize = isSmall ? 14 : isLarge ? 24 : 18;
    final double fontSize = isSmall ? 10 : isLarge ? 16 : 12;
    final double horizontalPadding = isSmall ? 6 : isLarge ? 20 : 12;
    final double verticalPadding = isSmall ? 8 : isLarge ? 20 : 16;

    return SizedBox(
      height: chipHeight + verticalPadding * 2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[index],
                  size: iconSize,
                  color: selectedIndex == index
                      ? Colors.white
                      : Theme.of(context).iconTheme.color,
                ),
                SizedBox(width: isSmall ? 3 : 6),
                Text(
                  categories[index],
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
            selected: selectedIndex == index,
            showCheckmark: false,
            onSelected: (selected) {
              if (selected) onCategorySelected(index);
            },
          ),
        ),
      ),
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(20)), // Reduced border radius
      child: Container(
        height: 28, // Reduced height
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2), // Reduced padding
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(20)), // Reduced border radius
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 12, // Reduced height for the icon
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 4), // Reduced spacing
            Text(
              category,
              style: TextStyle(
                fontSize: 10, // Reduced font size
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}