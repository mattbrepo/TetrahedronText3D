include <write.scad> // Write.scad by HarlanDMiiis licensed under the Creative Commons - https://www.thingiverse.com/thing:16193


//
// Get the point on the face of the tetrahedron defined by Pl, Pr, Pt:
//
//               Pt
//               /\    
//              /  \
//             /    \
//            /  ^w  \
//           /   |    \
//         Pl----Pm-->-Pr
//                   v
//
// Pm: middle point between Pl and Pr
// Pv: vector from Pm to Pr of length v
// Pw: vector from Pm to Pt of length w
function getTetraPoint(v, w, sideTriangle, heightTriangle, Pl, Pr, Pt) =
  // Pm = Pl + half of the side times the unit vector from PlPr
  let (Pm = Pl + (sideTriangle / 2) * ((Pr - Pl) / sideTriangle))
  let (Pv = v * ((Pr - Pm) / (sideTriangle / 2)))
  let (Pw = w * ((Pt - Pm) / heightTriangle))
    Pm + Pv + Pw; // linear combination

//
// Write tetrahedron text
//
// Pl, Pr, Pt: point of the face (as for getTetraPoint)
// Tl, Tr, Tt: text for left, right and top
// angleX, angleY, angleZ: rotations for font
// sideTriangle, heightTriangle: triangle dimensions
// font1H, font2H: fonts height
module writeTetra(sideName, Pl, Pr, Pt, Tl, Tr, Tt, angleX, angleY, angleZ, sideTriangle, heightTriangle, font1H, font2H) {
  Pc = getTetraPoint(0, heightTriangle / 2 - font1H / 2, sideTriangle, heightTriangle, Pl, Pr, Pt);
  translate(Pc)
    rotate(angleZ, [0, 0, 1])
      rotate(angleX, [1, 0, 0])
        rotate(angleY, [0, 1, 0])
          write(sideName, h=font1H, t=font1T, center=true);
  
  // text top
  Ptt = getTetraPoint(0, heightTriangle - 1.5 * font2H, sideTriangle, heightTriangle, Pl, Pr, Pt);
  translate(Ptt)
    rotate(angleZ, [0, 0, 1])
      rotate(angleX, [1, 0, 0])
        rotate(angleY, [0, 1, 0])
          write(Tt, h=font2H, t=font2T, center=true);

  // text left
  Ptl = getTetraPoint(-sideTriangle / 3.3, heightTriangle / 7, sideTriangle, heightTriangle, Pl, Pr, Pt);
  translate(Ptl)
    rotate(angleZ, [0, 0, 1])
      rotate(angleX, [1, 0, 0])
        rotate(angleY, [0, 1, 0])
          rotate(-45, [0, 0, 1])
            write(Tl, h=font2H, t=font2T, center=true);

  // text right
  Ptr = getTetraPoint(sideTriangle / 3.3, heightTriangle / 7, sideTriangle, heightTriangle, Pl, Pr, Pt);
  translate(Ptr)
    rotate(angleZ, [0, 0, 1])
      rotate(angleX, [1, 0, 0])
        rotate(angleY, [0, 1, 0])
          rotate(45, [0, 0, 1])
            write(Tr, h=font2H, t=font2T, center=true);
}

//
// --- MAIN
//

a = 50; // triangle / tetrahedron side length

// font central
font1H = 8;
font1T = 2; // depth

// second font
font2H = 6.5;
font2T = 1.5; // depth

difference(){ // extrusion

  // --- equilateral triangle / tetrahedron math
  // sources:
  // https://en.wikipedia.org/wiki/Equilateral_triangle
  // https://en.wikipedia.org/wiki/Tetrahedron

  // height of the equilateral triangle
  hTri = a * (sqrt(3) / 2);

  // radius of the inscribed circle of the triangle
  rTri = hTri / 3;

  // height of the tetrahedron
  hTet = a * sqrt(2 / 3);
      
  // angles of the tetrahedron
  edgeSideAngle = acos(hTet / a);
  sideSideAngle = asin(hTet / hTri);
  edgeEdgeAngle = 60; // OpenSCAD angles are in degrees
  
  // 4 vertices of the tetrahedron
  Pbase1 = [0, 0, 0]; // equilateral triangle
  Pbase2 = [a, 0, 0];
  Pbase3 = [a / 2, hTri, 0];
  Ppick = [a / 2, rTri, hTet]; // pick of the tetrahedron

  // prodebug    
  //echo("hTri");
  //echo(hTri);
  //echo("hTet");
  //echo(hTet);
  //echo("rTri");
  //echo(rTri);

  // --- tetrahedron
  polyhedron(
      points = [Pbase1, Pbase2, Pbase3, Ppick],
      faces = [
          [0, 1, 2], // base
          [0, 3, 1], // face 1
          [0, 2, 3], // face 2
          [1, 3, 2]  // face 3
      ]
  );

  // --- writing on base
  writeTetra("acl", Pbase2, Pbase1, Pbase3, "Y", "X", "Z", 0, 180, 0, a, hTri, font1H, font2H);

  // --- writing face 1
  writeTetra("B @", Pbase1, Pbase2, Ppick, "X", "Y", "F", sideSideAngle, 0, 0, a, hTri, font1H, font2H);

  // --- writing face 2
  writeTetra("B @", Pbase3, Pbase1, Ppick, "Z", "X", "F", sideSideAngle, 0, 240, a, hTri, font1H, font2H);

  // --- writing face 3
  writeTetra("B @", Pbase2, Pbase3, Ppick, "Y", "Z", "F", sideSideAngle, 0, 120, a, hTri, font1H, font2H);
}
