// lib/utils/parametros_laboratorio_adulto.dart
//
// Fichitas de valores de laboratorio del adulto que aparecen debajo de los
// campos de signos vitales. Son SOLO de consulta: no se captura nada ni se
// interpreta nada. Cada una muestra su rango normal y, al tocarla, un texto
// corto con lo que le sirve a enfermería.
//
// Por qué `const` y no JSON + SQLite: es una lista corta que no cambia sin
// una versión nueva de la app, igual que las tablas de signos vitales.
// Editarla aquí NO requiere subir la versión de la base de datos.
//
// Las referencias NO van en las fichitas (decisión de Diego): viven en la
// pestaña de Información (`scales_data.json`, entrada
// "signos_vitales_adulto"). Si cambias una cifra aquí, cambia también la
// referencia allá.
//
// Fuente de cada rango (valores "de libro", decisión de Diego):
//   - Glucosa: NOM-015-SSA2-2010 (normal en ayuno <100; anormal 100-125;
//     diabetes ≥126) y ADA, Standards of Care 2026, sección 6 (hipoglucemia
//     nivel 1 <70, nivel 2 <54).
//   - Sodio: MedlinePlus, "Examen de sodio en la sangre".
//   - Potasio: Medscape, "Potassium: Reference Range".
//   - Albúmina: Medscape, "Albumin: Reference Range".
//   - Hemoglobina, leucocitos: MedlinePlus, "Conteo sanguíneo completo".
//   - Plaquetas: MedlinePlus, "Conteo de plaquetas" (coincide con Cleveland
//     Clinic).
//   - Gasometría arterial: Michigan Medicine, Pathology Handbook, "Blood Gas
//     Reference Ranges".

class ParametroLaboratorio {
  final String nombre;

  /// Una línea por valor. La mayoría tiene una sola; hemoglobina separa
  /// hombre y mujer, y la gasometría trae un renglón por componente.
  final List<String> valores;

  /// Lo que se despliega al tocar la fichita. Texto corto, sin referencias.
  final String detalle;

  const ParametroLaboratorio({
    required this.nombre,
    required this.valores,
    required this.detalle,
  });
}

const List<ParametroLaboratorio> parametrosLaboratorioAdulto = [
  ParametroLaboratorio(
    nombre: 'Glucosa en ayuno',
    valores: ['70 - 99 mg/dL'],
    detalle:
        'De 100 a 125 en ayuno es glucosa anormal en ayuno; 126 o más sugiere '
        'diabetes y se confirma con otra prueba. Menos de 70 es hipoglucemia y '
        'menos de 54 es hipoglucemia clínicamente significativa. Una glucemia '
        'capilar fuera de ayuno no se compara contra este rango.',
  ),
  ParametroLaboratorio(
    nombre: 'Sodio',
    valores: ['135 - 145 mEq/L'],
    detalle:
        'Por debajo, hiponatremia; por arriba, hipernatremia. Ambas se '
        'manifiestan sobre todo en el estado neurológico: confusión, letargo, '
        'convulsiones. La corrección debe ser lenta y vigilada, porque '
        'corregir demasiado rápido también daña el sistema nervioso.',
  ),
  ParametroLaboratorio(
    nombre: 'Potasio',
    valores: ['3.5 - 5.0 mEq/L'],
    detalle:
        'Tanto la hipopotasemia como la hiperpotasemia pueden causar '
        'arritmias graves. Una muestra hemolizada da un potasio falsamente '
        'alto. El cloruro de potasio intravenoso nunca se administra en bolo: '
        'siempre diluido y en infusión controlada.',
  ),
  ParametroLaboratorio(
    nombre: 'Albúmina',
    valores: ['3.5 - 5.5 g/dL'],
    detalle:
        'Baja en desnutrición, hepatopatía, síndrome nefrótico e inflamación. '
        'La hipoalbuminemia reduce la presión oncótica y favorece el edema. '
        'Con albúmina baja, el calcio total se lee falsamente bajo.',
  ),
  ParametroLaboratorio(
    nombre: 'Hemoglobina',
    valores: ['Hombre 13 - 18 g/dL', 'Mujer 12 - 16 g/dL'],
    detalle:
        'Por debajo del límite inferior se considera anemia. En la población '
        'que reside a mayor altitud, los valores normales tienden a ser algo '
        'más altos que a nivel del mar.',
  ),
  ParametroLaboratorio(
    nombre: 'Leucocitos',
    valores: ['4,500 - 11,000 /µL'],
    detalle:
        'Por arriba, leucocitosis: infección, inflamación, estrés o uso de '
        'esteroides. Por abajo, leucopenia, con mayor riesgo de infección. En '
        'el paciente neutropénico la cifra que guía los cuidados es la de '
        'neutrófilos absolutos, no la de leucocitos totales.',
  ),
  ParametroLaboratorio(
    nombre: 'Plaquetas',
    valores: ['150,000 - 400,000 /µL'],
    detalle:
        'Por debajo de 150,000, trombocitopenia: vigilar sangrado de encías, '
        'petequias, hematomas y sangrado en sitios de punción, y ejercer '
        'presión más prolongada al retirar un catéter o una aguja.',
  ),
  ParametroLaboratorio(
    nombre: 'Gasometría arterial',
    valores: [
      'pH 7.35 - 7.45',
      'PaCO2 35 - 45 mmHg',
      'HCO3 22 - 26 mEq/L',
      'PaO2 80 - 100 mmHg',
    ],
    detalle:
        'pH menor de 7.35 es acidosis y mayor de 7.45, alcalosis. Si la PaCO2 '
        'explica el cambio (alta con acidosis, baja con alcalosis), el origen '
        'es respiratorio; si lo explica el HCO3 (bajo con acidosis, alto con '
        'alcalosis), es metabólico. Son valores a nivel del mar: en altitud, '
        'la PaO2 y la PaCO2 normales son más bajas.',
  ),
];
