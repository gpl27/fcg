#version 330 core

// Atributos de vértice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a função BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Variáveis do modelo de iluminação
uniform uint light_model;
uniform uint shading;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage;

// Atributos de vértice que serão gerados como saída ("out") pelo Vertex Shader.
// ** Estes serão interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais serão recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;
out vec4 color_v;

void main()
{

    gl_Position = projection * view * model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    // Normal do vértice atual no sistema de coordenadas global (World).
    // Veja slides 123-151 do documento Aula_07_Transformacoes_Geometricas_3D.pdf.
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
    texcoords = texture_coefficients;

    if (shading == uint(0)) { // Gourard Shading
        vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 camera_position = inverse(view) * origin;
        vec4 p = position_world;
        vec4 n = normalize(normal);
        vec4 v = normalize(camera_position - p);
        vec4 l = normalize(v);
        vec4 r = -l + 2*n*(dot(n, l)); 
        vec4 h = normalize(v + l);

        float U = texcoords.x;
        float V = texcoords.y;
        vec3 Kd0 = texture(TextureImage, vec2(U,V)).rgb;
        vec3 Ka = vec3(0.005, 0.005, 0.005);
        vec3 I = vec3(1.0, 1.0, 1.0); 
        vec3 Ia = vec3(1.0, 1.0, 1.0);
        // Termo difuso utilizando a lei dos cossenos de Lambert
        vec3 lambert_diffuse_term = Kd0*I*max(0, dot(n, l)); 
        // Termo ambiente
        vec3 ambient_term = Ka*Ia; 
        // Termo especular utilizando o modelo de iluminação de Phong
        vec3 blinn_phong_specular_term = vec3(0.0, 0.0, 0.0);
        if (light_model == uint(1)) {
            vec3 Ks = vec3(1.0, 1.0, 1.0);
            float ql = 80;
            blinn_phong_specular_term  = Ks*I*pow(max(0, dot(n, h)), ql); 
        }
        color_v.rgb = lambert_diffuse_term +  blinn_phong_specular_term;
    }
}

