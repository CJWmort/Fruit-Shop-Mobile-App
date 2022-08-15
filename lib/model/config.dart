class DrawerConfig{ //Control the drawer animation & position
  static double xOffset = 0;
  static double yOffset = 0;
  static double scaleFactor = 1;
  static bool isDrawerOpen = false;
}

void closeDrawer(){
  DrawerConfig.xOffset = 0;
  DrawerConfig.yOffset = 0;
  DrawerConfig.scaleFactor = 1;
  DrawerConfig.isDrawerOpen = false;
}

void openDrawer(){
  DrawerConfig.xOffset = 210;
  DrawerConfig.yOffset = 105;
  DrawerConfig.scaleFactor = 0.7;
  DrawerConfig.isDrawerOpen = true;
}

