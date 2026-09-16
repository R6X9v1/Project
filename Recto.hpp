#ifndef RECTO_HPP
#define RECTO_HPP

#include <string>
#include <algorithm>

class Recto {
public:
    float x;
    float y;
    float w;
    float h;

    Recto() : x(0), y(0), w(0), h(0) {}
    Recto(float x, float y, float w, float h) : x(x), y(y), w(w), h(h) {}

    float right() const { return x + w; }
    float bottom() const { return y + h; }
    float area() const { return w * h; }

    bool intersects(const Recto &other) const {
        return !(other.x > right() || other.right() < x ||
                 other.y > bottom() || other.bottom() < y);
    }

    bool contains(const Recto &other) const {
        return (other.x >= x && other.right() <= right() &&
                other.y >= y && other.bottom() <= bottom());
    }

    bool contains_point(float px, float py) const {
        return (px >= x && px <= right() && py >= y && py <= bottom());
    }

    void expand_to_include(const Recto &other) {
        float new_x = std::min(x, other.x);
        float new_y = std::min(y, other.y);
        float new_right = std::max(right(), other.right());
        float new_bottom = std::max(bottom(), other.bottom());
        x = new_x;
        y = new_y;
        w = new_right - new_x;
        h = new_bottom - new_y;
    }

    void translate(float dx, float dy) {
        x += dx;
        y += dy;
    }

    bool operator==(const Recto &other) const {
        return (x == other.x && y == other.y && w == other.w && h == other.h);
    }

    bool operator!=(const Recto &other) const {
        return !(*this == other);
    }

    std::string to_string() const {
        return "Recto(x=" + std::to_string(x) + ", y=" + std::to_string(y) +
               ", w=" + std::to_string(w) + ", h=" + std::to_string(h) + ")";
    }

    //TESTE INIT
	int get_max_width() {
		return (this->x + this->w);
	}

	int get_max_height() {
		return (this->y + this->h);
	}
	//TESTE FINISH
};

#endif // RECTO_HPP