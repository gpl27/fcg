#include "collisions.h"
#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>

bool point_plane_collision(glm::vec3 p, glm::vec3 pmin, glm::vec3 pmax) {
    if (p.y > pmin.y) {
        return false; 
    }

    bool overlap_x = p.x < pmax.x && p.x > pmin.x;
    bool overlap_z = p.z < pmax.z && p.z > pmin.z;

    return overlap_x && overlap_z;
}

bool cube_cube_collision(const glm::vec4& cmin1, const glm::vec4& cmax1, const glm::vec4& cmin2, const glm::vec4& cmax2) {
    bool overlapX = cmax1.x >= cmin2.x && cmin1.x <= cmax2.x;

    bool overlapY = cmax1.y >= cmin2.y && cmin1.y <= cmax2.y;

    bool overlapZ = cmax1.z >= cmin2.z && cmin1.z <= cmax2.z;

    return overlapX && overlapY && overlapZ;
}

bool point_cube_collision(const glm::vec3& point, const glm::vec4& minCorner, const glm::vec4& maxCorner) {
    return (point.x >= minCorner.x && point.x <= maxCorner.x) &&
           (point.y >= minCorner.y && point.y <= maxCorner.y) &&
           (point.z >= minCorner.z && point.z <= maxCorner.z);
}

