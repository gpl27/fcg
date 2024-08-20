#ifndef _COLLISIONS_H
#define _COLLISIONS_H

#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>

bool point_plane_collision(glm::vec3 p, glm::vec3 pmin, glm::vec3 pmax);

bool cube_cube_collision(const glm::vec4& cmin1, const glm::vec4& cmax1, const glm::vec4& cmin2, const glm::vec4& cmax2);

bool point_cube_collision(const glm::vec3& point, const glm::vec4& minCorner, const glm::vec4& maxCorner);


#endif 