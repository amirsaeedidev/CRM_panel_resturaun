import 'package:flutter/material.dart';

/// Navigation item model representing a single menu entry
/// 
/// Supports:
/// - Title and subtitle
/// - Icon and selected icon
/// - Route path and name
/// - Badge for notifications or counts
/// - Active state tracking
/// - Nested children for expandable menus
/// - Permission requirements (future support)
/// - Role requirements (future support)
class NavigationItem {
  /// Unique identifier for the navigation item
  final String id;

  /// Display title of the navigation item
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Icon displayed when item is not selected
  final IconData icon;

  /// Icon displayed when item is selected
  final IconData? selectedIcon;

  /// Route path for navigation
  final String routePath;

  /// Route name for programmatic navigation
  final String? routeName;

  /// Optional badge value (e.g., notification count)
  final String? badge;

  /// Whether this item is currently active
  final bool isActive;

  /// Whether this item is enabled
  final bool isEnabled;

  /// Nested child items for expandable menus
  final List<NavigationItem> children;

  /// Required permissions to access this item (future support)
  final List<String> requiredPermissions;

  /// Required roles to access this item (future support)
  final List<String> requiredRoles;

  /// Callback when item is tapped
  final VoidCallback? onTap;

  const NavigationItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    this.selectedIcon,
    required this.routePath,
    this.routeName,
    this.badge,
    this.isActive = false,
    this.isEnabled = true,
    this.children = const [],
    this.requiredPermissions = const [],
    this.requiredRoles = const [],
    this.onTap,
  });

  /// Check if this item has children
  bool get hasChildren => children.isNotEmpty;

  /// Check if this item requires permissions
  bool get requiresPermissions => requiredPermissions.isNotEmpty;

  /// Check if this item requires roles
  bool get requiresRoles => requiredRoles.isNotEmpty;

  /// Get the effective icon based on selection state
  IconData get effectiveIcon => isActive && selectedIcon != null 
      ? selectedIcon! 
      : icon;

  /// Create a copy of this item with updated fields
  NavigationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    IconData? selectedIcon,
    String? routePath,
    String? routeName,
    String? badge,
    bool? isActive,
    bool? isEnabled,
    List<NavigationItem>? children,
    List<String>? requiredPermissions,
    List<String>? requiredRoles,
    VoidCallback? onTap,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      routePath: routePath ?? this.routePath,
      routeName: routeName ?? this.routeName,
      badge: badge ?? this.badge,
      isActive: isActive ?? this.isActive,
      isEnabled: isEnabled ?? this.isEnabled,
      children: children ?? this.children,
      requiredPermissions: requiredPermissions ?? this.requiredPermissions,
      requiredRoles: requiredRoles ?? this.requiredRoles,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.icon == icon &&
        other.selectedIcon == selectedIcon &&
        other.routePath == routePath &&
        other.routeName == routeName &&
        other.badge == badge &&
        other.isActive == isActive &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        subtitle,
        icon,
        selectedIcon,
        routePath,
        routeName,
        badge,
        isActive,
        isEnabled,
      );
}