{pointTriangleDist} = require '/dist3d'

return class BounceModel extends require('/webgl/drawable')
    attribs: ['position', 'texcoord', 'normal', 'lightprobe']
    pointers: [
        {name: 'position', size: 3, offset: 0, stride: 12},
        {name: 'texcoord', size: 2, offset: 3, stride: 12},
        {name: 'normal', size: 3, offset: 5, stride: 12},
        {name: 'lightprobe', size: 4, offset: 8, stride: 12},
    ]

    constructor: (@gl, model, probes) ->
        super()

        start = gettime()

        vertices = model.vertices
        vertex_count = vertices.length/8
        face_count = vertex_count/3

        result = []

        for i in [0...face_count]
            verti = i*3

            vali = verti*8
            x1 = vertices[vali+0]
            y1 = vertices[vali+1]
            z1 = vertices[vali+2]
            u1 = vertices[vali+3]
            v1 = vertices[vali+4]
            nx1 = vertices[vali+5]
            ny1 = vertices[vali+6]
            nz1 = vertices[vali+7]
            
            vali = verti*8+8
            x2 = vertices[vali+0]
            y2 = vertices[vali+1]
            z2 = vertices[vali+2]
            u2 = vertices[vali+3]
            v2 = vertices[vali+4]
            nx2 = vertices[vali+5]
            ny2 = vertices[vali+6]
            nz2 = vertices[vali+7]
            
            vali = verti*8+16
            x3 = vertices[vali+0]
            y3 = vertices[vali+1]
            z3 = vertices[vali+2]
            u3 = vertices[vali+3]
            v3 = vertices[vali+4]
            nx3 = vertices[vali+5]
            ny3 = vertices[vali+6]
            nz3 = vertices[vali+7]
            for probe, i in probes
                px = probe.x; py = probe.y; pz = probe.z

                dx1 = px-x1; dy1 = py-y1; dz1 = pz-z1
                l = Math.sqrt(dx1*dx1+dy1*dy1+dz1*dz1)
                dx1/=l; dy1/=l; dz1/=l
                dot1 = dx1*nx1 + dy1*ny1 + dz1*nz1
                
                dx2 = px-x2; dy2 = py-y2; dz2 = pz-z2
                l = Math.sqrt(dx2*dx2+dy2*dy2+dz2*dz2)
                dx2/=l; dy2/=l; dz2/=l
                dot2 = dx2*nx2 + dy2*ny2 + dz2*nz2
                
                dx3 = px-x3; dy3 = py-y3; dz3 = pz-z3
                l = Math.sqrt(dx3*dx3+dy3*dy3+dz3*dz3)
                dx3/=l; dy3/=l; dz3/=l
                dot3 = dx3*nx3 + dy3*ny3 + dz3*nz3
            
                
                # triangle plane
                tx=x2-x1; ty=y2-y1; tz=z2-z1
                btx=x3-x1; bty=y3-y1; btz=z3-z1

                fnx = ty*btz - tz*bty
                fny = tz*btx - tx*btz
                fnz = tx*bty - ty*btx
                l = Math.sqrt(fnx*fnx + fny*fny + fnz*fnz)
                fnx/=l; fny/=l; fnz/=l
                det = fnx*x1 + fny*y1 + fnz*z1
                dist = Math.abs((fnx*px + fny*py + fnz*pz)-det)

                if (dot1 >= 0 or dot2 >= 0 or dot3 >= 0) and dist <= 5.0
                    if pointTriangleDist([px, py, pz], [x1, y1, z1], [x2, y2, z2], [x3, y3, z3]) <= 5.0
                        result.push(
                            x1, y1, z1, u1, v1, nx1, ny1, nz1, px, py, pz, i,
                            x2, y2, z2, u2, v2, nx2, ny2, nz2, px, py, pz, i,
                            x3, y3, z3, u3, v3, nx3, ny3, nz3, px, py, pz, i,
                        )

        #console.log (result.length/12)/((vertices.length/8)*probes.length)
        @size = result.length/12
        @uploadList result
        #console.log gettime() - start

