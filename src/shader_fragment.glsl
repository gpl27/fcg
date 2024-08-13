#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;
in vec4 color_v;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define PIPE 0
#define BRICK  1
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage;

// Variáveis do modelo de iluminação
uniform uint light_model;
uniform uint shading;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec4 color;

void main()
{
    if (shading == uint(0)) { // Gourard Shading
        color = color_v;
    } else {
        // Obtemos a posição da câmera utilizando a inversa da matriz que define o
        // sistema de coordenadas da câmera.
        vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 camera_position = inverse(view) * origin;

        // O fragmento atual é coberto por um ponto que percente à superfície de um
        // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
        // sistema de coordenadas global (World coordinates). Esta posição é obtida
        // através da interpolação, feita pelo rasterizador, da posição de cada
        // vértice.
        vec4 p = position_world;

        // Normal do fragmento atual, interpolada pelo rasterizador a partir das
        // normais de cada vértice.
        vec4 n = normalize(normal);

        // Vetor que define o sentido da câmera em relação ao ponto atual.
        vec4 v = normalize(camera_position - p);
        // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
        vec4 l = normalize(v);

        vec4 r = -l + 2*n*(dot(n, l)); 

        // Half-vector de Blinn-Phong
        vec4 h = normalize(v + l);


        // Coordenadas de textura U e V
        float U = texcoords.x;
        float V = texcoords.y;
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
        vec3 Kd0 = texture(TextureImage, vec2(U,V)).rgb;
        vec3 Ka = vec3(0.005, 0.005, 0.005);

        // Espectro da fonte de iluminação
        vec3 I = vec3(1.0, 1.0, 1.0); 

        // Espectro da luz ambiente
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

        color.rgb = lambert_diffuse_term +  blinn_phong_specular_term;
    }

    color.a = 1;

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
} 

