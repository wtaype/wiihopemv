class wii {
  static const String app = 'WiiHope';
  static const int lanzamiento = 2024;
  static const String autor = '@wilder.taype';
  static const String link = 'https://wtaype.github.io/';
  static const String version = 'v13.1.1';
}

/** Actualizar main luego esto, pero si es mucho, solo esto. (1)
git tag v13 -m "Version v13" ; git push origin v13

//  ACTUALIZACIÓN PRINCIPAL ONE DEV [START] (2)
git add . ; git commit -m "Actualizacion Principal v13.10.10" ; git push origin main

// En caso de emergencia, para actualizar el Tag existente. (3)
git tag -d v13 ; git tag v13 -m "Version v13 actualizada" ; git push origin v11 --force
 ACTUALIZACION TAG[END] */
