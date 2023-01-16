"use strict";
(() => {
    var v = Uint8Array,
        A = Uint16Array,
        _ = Uint32Array,
        rr = new v([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 0, 0, 0]),
        nr = new v([0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 0, 0]),
        lr = new v([16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]),
        tr = function (r, n) {
            for (var t = new A(31), e = 0; e < 31; ++e) t[e] = n += 1 << r[e - 1];
            for (var a = new _(t[30]), e = 1; e < 30; ++e)
                for (var u = t[e]; u < t[e + 1]; ++u) a[u] = u - t[e] << 5 | e;
            return [t, a]
        },
        er = tr(rr, 2),
        ir = er[0],
        cr = er[1];
    ir[28] = 258, cr[258] = 28;
    var ar = tr(nr, 0),
        pr = ar[0],
        Ur = ar[1],
        q = new A(32768);
    for (o = 0; o < 32768; ++o) m = (o & 43690) >>> 1 | (o & 21845) << 1, m = (m & 52428) >>> 2 | (m & 13107) << 2, m = (m & 61680) >>> 4 | (m & 3855) << 4, q[o] = ((m & 65280) >>> 8 | (m & 255) << 8) >>> 1;
    var m, o, D = function (r, n, t) {
        for (var e = r.length, a = 0, u = new A(n); a < e; ++a) r[a] && ++u[r[a] - 1];
        var g = new A(n);
        for (a = 0; a < n; ++a) g[a] = g[a - 1] + u[a - 1] << 1;
        var s;
        if (t) {
            s = new A(1 << n);
            var i = 15 - n;
            for (a = 0; a < e; ++a)
                if (r[a])
                    for (var f = a << 4 | r[a], h = n - r[a], l = g[r[a] - 1]++ << h, w = l | (1 << h) - 1; l <= w; ++l) s[q[l] >>> i] = f
        } else
            for (s = new A(e), a = 0; a < e; ++a) r[a] && (s[a] = q[g[r[a] - 1]++] >>> 15 - r[a]);
        return s
    },
        E = new v(288);
    for (o = 0; o < 144; ++o) E[o] = 8;
    var o;
    for (o = 144; o < 256; ++o) E[o] = 9;
    var o;
    for (o = 256; o < 280; ++o) E[o] = 7;
    var o;
    for (o = 280; o < 288; ++o) E[o] = 8;
    var o, or = new v(32);
    for (o = 0; o < 32; ++o) or[o] = 5;
    var o;
    var gr = D(E, 9, 1);
    var yr = D(or, 5, 1),
        R = function (r) {
            for (var n = r[0], t = 1; t < r.length; ++t) r[t] > n && (n = r[t]);
            return n
        },
        p = function (r, n, t) {
            var e = n / 8 | 0;
            return (r[e] | r[e + 1] << 8) >> (n & 7) & t
        },
        $ = function (r, n) {
            var t = n / 8 | 0;
            return (r[t] | r[t + 1] << 8 | r[t + 2] << 16) >> (n & 7)
        },
        wr = function (r) {
            return (r + 7) / 8 | 0
        },
        mr = function (r, n, t) {
            (n == null || n < 0) && (n = 0), (t == null || t > r.length) && (t = r.length);
            var e = new (r.BYTES_PER_ELEMENT == 2 ? A : r.BYTES_PER_ELEMENT == 4 ? _ : v)(t - n);
            return e.set(r.subarray(n, t)), e
        };
    var xr = ["unexpected EOF", "invalid block type", "invalid length/literal", "invalid distance", "stream finished", "no stream handler", , "no callback", "invalid UTF-8 data", "extra field too long", "date not in range 1980-2099", "filename too long", "stream finishing", "invalid zip data"],
        x = function (r, n, t) {
            var e = new Error(n || xr[r]);
            if (e.code = r, Error.captureStackTrace && Error.captureStackTrace(e, x), !t) throw e;
            return e
        },
        zr = function (r, n, t) {
            var e = r.length;
            if (!e || t && t.f && !t.l) return n || new v(0);
            var a = !n || t,
                u = !t || t.i;
            t || (t = {}), n || (n = new v(e * 3));
            var g = function (V) {
                var X = n.length;
                if (V > X) {
                    var b = new v(Math.max(X * 2, V));
                    b.set(n), n = b
                }
            },
                s = t.f || 0,
                i = t.p || 0,
                f = t.b || 0,
                h = t.l,
                l = t.d,
                w = t.m,
                T = t.n,
                I = e * 8;
            do {
                if (!h) {
                    s = p(r, i, 1);
                    var B = p(r, i + 1, 3);
                    if (i += 3, B)
                        if (B == 1) h = gr, l = yr, w = 9, T = 5;
                        else if (B == 2) {
                            var G = p(r, i, 31) + 257,
                                Y = p(r, i + 10, 15) + 4,
                                W = G + p(r, i + 5, 31) + 1;
                            i += 14;
                            for (var C = new v(W), O = new v(19), c = 0; c < Y; ++c) O[lr[c]] = p(r, i + c * 3, 7);
                            i += Y * 3;
                            for (var j = R(O), sr = (1 << j) - 1, ur = D(O, j, 1), c = 0; c < W;) {
                                var d = ur[p(r, i, sr)];
                                i += d & 15;
                                var y = d >>> 4;
                                if (y < 16) C[c++] = y;
                                else {
                                    var S = 0,
                                        F = 0;
                                    for (y == 16 ? (F = 3 + p(r, i, 3), i += 2, S = C[c - 1]) : y == 17 ? (F = 3 + p(r, i, 7), i += 3) : y == 18 && (F = 11 + p(r, i, 127), i += 7); F--;) C[c++] = S
                                }
                            }
                            var J = C.subarray(0, G),
                                z = C.subarray(G);
                            w = R(J), T = R(z), h = D(J, w, 1), l = D(z, T, 1)
                        } else x(1);
                    else {
                        var y = wr(i) + 4,
                            Z = r[y - 4] | r[y - 3] << 8,
                            k = y + Z;
                        if (k > e) {
                            u && x(0);
                            break
                        }
                        a && g(f + Z), n.set(r.subarray(y, k), f), t.b = f += Z, t.p = i = k * 8, t.f = s;
                        continue
                    }
                    if (i > I) {
                        u && x(0);
                        break
                    }
                }
                a && g(f + 131072);
                for (var vr = (1 << w) - 1, hr = (1 << T) - 1, L = i; ; L = i) {
                    var S = h[$(r, i) & vr],
                        M = S >>> 4;
                    if (i += S & 15, i > I) {
                        u && x(0);
                        break
                    }
                    if (S || x(2), M < 256) n[f++] = M;
                    else if (M == 256) {
                        L = i, h = null;
                        break
                    } else {
                        var K = M - 254;
                        if (M > 264) {
                            var c = M - 257,
                                U = rr[c];
                            K = p(r, i, (1 << U) - 1) + ir[c], i += U
                        }
                        var P = l[$(r, i) & hr],
                            N = P >>> 4;
                        P || x(3), i += P & 15;
                        var z = pr[N];
                        if (N > 3) {
                            var U = nr[N];
                            z += $(r, i) & (1 << U) - 1, i += U
                        }
                        if (i > I) {
                            u && x(0);
                            break
                        }
                        a && g(f + 131072);
                        for (var Q = f + K; f < Q; f += 4) n[f] = n[f - z], n[f + 1] = n[f + 1 - z], n[f + 2] = n[f + 2 - z], n[f + 3] = n[f + 3 - z];
                        f = Q
                    }
                }
                t.l = h, t.p = L, t.b = f, t.f = s, h && (s = 1, t.m = w, t.d = l, t.n = T)
            } while (!s);
            return f == n.length ? n : mr(n, 0, f)
        };
    var Ar = new v(0);
    var Sr = function (r) {
        (r[0] != 31 || r[1] != 139 || r[2] != 8) && x(6, "invalid gzip data");
        var n = r[3],
            t = 10;
        n & 4 && (t += r[10] | (r[11] << 8) + 2);
        for (var e = (n >> 3 & 1) + (n >> 4 & 1); e > 0; e -= !r[t++]);
        return t + (n & 2)
    },
        Mr = function (r) {
            var n = r.length;
            return (r[n - 4] | r[n - 3] << 8 | r[n - 2] << 16 | r[n - 1] << 24) >>> 0
        };

    function H(r, n) {
        return zr(r.subarray(Sr(r), -8), n || new v(Mr(r)))
    }
    var Tr = typeof TextDecoder < "u" && new TextDecoder,
        Cr = 0;
    try {
        Tr.decode(Ar, {
            stream: !0
        }), Cr = 1
    } catch { }
    var fr = () => {
        var n;
        let r = document.querySelectorAll('script[type="text/javascript+gzip"][src]');
        for (let t of r) try {
            let e = t.src.match(/^data:(.*?)(?:;(base64))?,(.*)$/);
            if (!e) continue;
            let [a, u, g, s] = e, i = Uint8Array.from(g ? atob(s) : decodeURIComponent(s), w => w.charCodeAt(0)), h = new TextDecoder().decode(H(i)), l = document.createElement("script");
            l.textContent = h, (n = t.parentNode) == null || n.replaceChild(l, t)
        } catch (e) {
            console.error("Could not gunzip script", t, e)
        }
    };
    fr();
    window.gunzipSync = H;
    window.gunzipScripts = fr;
})();