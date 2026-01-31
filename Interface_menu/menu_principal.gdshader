shader_type canvas_item;

// Color de la lluvia 
uniform vec3 rain_color: source_color = vec3(0.0, 1.0, 0.0); 
// Color del easter egg
uniform vec3 easter_egg_color: source_color = vec3(1.0, 0.0, 1.0); // Magenta
// Velocidad de caída
uniform float speed: hint_range(0.1, 5.0) = 1.0;
// Densidad: 
uniform float density: hint_range(30.0, 300.0) = 100.0; 
// Ancho de columna: 
uniform float column_width: hint_range(0.1, 1.0) = 0.5;
// Easter Egg: Probabilidad de aparición (0.0 = nunca, 1.0 = siempre)
uniform float easter_egg_chance: hint_range(0.0, 1.0) = 0.05;

// Función de ruido aleatorio
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Función para detectar si estamos en una columna "UTCH"
bool is_utch_column(float column_id, float total_columns) {
    // Calculamos la posición central para las 4 letras
    float center = total_columns * 0.5;
    float utch_start = floor(center - 2.0);
    
    //
    return column_id >= utch_start && column_id < utch_start + 4.0;
}

// Patrón simple para simular letras 
float get_letter_pattern(float column_index, vec2 cell_uv, float time_val) {
    // Cada columna representa una letra: U, T, C, H
    float local_column = mod(column_index, 4.0);
    
    // Zona donde aparecen las letras 
    float letter_zone = smoothstep(0.3, 0.4, fract(time_val * 0.1)) * 
                       smoothstep(0.7, 0.6, fract(time_val * 0.1));
    
    // Patrón de intensidad que hace que parezca una letra
    float pattern = 0.0;
    
    if (local_column < 1.0) {
        // U: más brillante en los bordes
        pattern = step(0.2, cell_uv.x) * step(cell_uv.x, 0.3) + 
                 step(0.7, cell_uv.x) * step(cell_uv.x, 0.8) +
                 step(0.8, cell_uv.y);
    } else if (local_column < 2.0) {
        // T: brillante arriba y en el centro
        pattern = step(cell_uv.y, 0.2) + 
                 step(0.4, cell_uv.x) * step(cell_uv.x, 0.6);
    } else if (local_column < 3.0) {
        // C: brillante en el borde izquierdo
        pattern = step(0.2, cell_uv.x) * step(cell_uv.x, 0.3) +
                 step(cell_uv.y, 0.2) + step(0.8, cell_uv.y);
    } else {
        // H: brillante en los bordes y centro
        pattern = step(0.2, cell_uv.x) * step(cell_uv.x, 0.3) + 
                 step(0.7, cell_uv.x) * step(cell_uv.x, 0.8) +
                 step(0.4, cell_uv.y) * step(cell_uv.y, 0.6);
    }
    
    return pattern * letter_zone;
}

void fragment() {
    vec2 uv = UV;
    float time_offset = TIME * speed;
    
    // Configuración de la cuadrícula 
    vec2 grid_uv = uv * vec2(density, 1.0);
    vec2 cell_id = floor(grid_uv);
    vec2 cell_inner_uv = fract(grid_uv); // Coordenadas dentro de cada "celda"
    
    // Generar la caída
    float drop = fract(grid_uv.y + time_offset + random(vec2(cell_id.x, 0.0)));
    
    // Rastro que se desvanece
    float trail = 1.0 - smoothstep(0.0, 1.0, drop);
    
    // Simulación de caracteres (parpadeo)
    float char_flicker = step(0.4, random(floor(grid_uv * vec2(1.0, 15.0)) + floor(TIME * 10.0)));
    
    // Recortamos los lados de la columna usando el 'column_width'
    float width_mask = step(0.5 - column_width / 2.0, cell_inner_uv.x) * 
                      step(cell_inner_uv.x, 0.5 + column_width / 2.0);
    
    //  EASTER EGG: Detectar si esta columna es especial
    float column_random = random(vec2(cell_id.x, floor(TIME * 0.5)));
    bool is_special = is_utch_column(cell_id.x, density) && column_random < easter_egg_chance;
    
    // Si es una columna especial, aplicar el patrón de letra
    float letter_effect = 0.0;
    vec3 final_color = rain_color;
    
    if (is_special) {
        letter_effect = get_letter_pattern(cell_id.x, cell_inner_uv, TIME);
        // Mezclar colores: el easter egg brilla más
        final_color = mix(rain_color, easter_egg_color, letter_effect * 0.8);
        // Hacer que las columnas UTCH brillen más
        trail = max(trail, letter_effect * 1.5);
    }
    
    // Combinar todo
    float final_alpha = trail * char_flicker * width_mask;
    
    // Aplicar color
    COLOR = vec4(final_color, final_alpha);
}