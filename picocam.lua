cameralib = {
  new = function(init)
    init = init or {}
    local self = {}
    self.z = init.z or -3
    self.focallength = init.focallength or 5
    self.fov = init.fov or 45
    self.theta = init.theta or 0
    self.width = init.width or 128
    self.height = init.height or 128
    -- public
    self.line = cameralib.line
    self.point = cameralib.point
    -- private
    self._perspective = cameralib._perspective
    self._tan = cameralib._tan
    self._coordstopx = cameralib._coordstopx
    self._map = cameralib._map
    return self
  end,
  line = function(self, p1, p2)
    local px_1 = self:_coordstopx(self._perspective(p1))
    local px_2 = self:_coordstopx(self._perspective(p2))
    line(px_1[1], px_1[2], px_2[1], px_2[2])
  end,
  point = function(self, p)
    local px = self:_coordstopx(self._perspective(p))
    pset(px[1],px[2])
  end,
  _perspective = function(p)
    local x,y,z = p[1],p[2],p[3]
    local x_rot = x * cos(camera.theta) - z * sin(camera.theta)
    local z_rot = x * sin(camera.theta) + z * cos(camera.theta)
    x = x_rot
    z = z_rot
    local dz = z - camera.z
    local out_z = camera.z + camera.focallength
    local m_xz = x / dz
    local m_yz = y / dz
    local out_x = m_xz * out_z
    local out_y = m_yz * out_z
    return { out_x, out_y }
  end,
  _map = function(v, a, b, c, d)
    local partial = (v - a) / (b - a)
    return partial * (d - c) + c
  end,
  _tan = function(v)
    return sin(v) / cos(v)
  end,
  _coordstopx = function(self,coords)
    local x = coords[1]
    local y = coords[2]
    local radius = camera.focallength * self._tan(camera.fov / 2 / 360)
    local pixel_x = self._map(x, -radius, radius, 0, camera.width)
    local pixel_y = self._map(y, -radius, radius, 0, camera.height)
    return { pixel_x, pixel_y }
  end,
}
