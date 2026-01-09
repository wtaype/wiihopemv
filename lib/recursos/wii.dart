class wii {
  static const String app = 'WiiHope';
  static const int lanzamiento = 2024;
  static const String autor = '@wilder.taype';
  static const String link = 'https://wtaype.github.io/';
  static const String version = 'v11';
}

/** Actualizar main luego esto, pero si es mucho, solo esto. (1)
git tag v11 -m "Version v11" ; git push origin v11

//  ACTUALIZACIÓN PRINCIPAL ONE DEV [START] (2)
git add . ; git commit -m "Actualizacion Principal v11.10.10" ; git push origin main

// En caso de emergencia, para actualizar el Tag existente. (3)
git tag -d v11 ; git tag v11 -m "Version v11 actualizada" ; git push origin v11 --force
 ACTUALIZACION TAG[END] */
