extern Image displacement_map;
 vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
  vec4 dp = Texel(displacement_map, tc);
  vec2 p = tc;
  p.x += (dp.r*2.0 - 1.0)*0.025*dp.a;
  p.y += (dp.g*2.0 - 1.0)*0.025*dp.a;
  return color*Texel(texture, p);
}
