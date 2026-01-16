class wii {
  static const String app = 'WiiHope';
  static const int lanzamiento = 2024;
  static const String autor = '@wilder.taype';
  static const String link = 'https://wtaype.github.io/';
  static const String version = 'v17.1.1';
}

/** Actualizar main luego esto, pero si es mucho, solo esto. (1)
git tag v17 -m "Version v17" ; git push origin v17

//  ACTUALIZACIÓN PRINCIPAL ONE DEV [START] (2)
git add . ; git commit -m "Actualizacion Principal v17.10.10" ; git push origin main

// En caso de emergencia, para actualizar el Tag existente. (3)
git tag -d v17 ; git tag v17 -m "Version v17 actualizada" ; git push origin v17 --force
 ACTUALIZACION TAG[END] */
