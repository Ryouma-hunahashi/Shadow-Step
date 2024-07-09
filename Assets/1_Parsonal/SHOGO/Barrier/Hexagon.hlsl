#ifndef SAMPLE_HEXAGON_INCLUDED
#define SAMPLE_HEXAGON_INCLUDED

void _GenerateHexagon_float(
in float2 _uv,
in float _scale,
out float _hexagon,
out float2 _hexPos,
out float2 _hexUV,
out float2 _hexIndex
)
{
    _hexPos = float2(0, 0);
    _hexUV = float2(0, 0);
    _hexIndex = float2(0, 0);
    
    float2 p = _uv * _scale;
    p.x *= 1.15470053838;
    float isTwo = frac(floor(p.x) / 2.0) * 2.0; // 偶数列目なら1.0
    float isOne = 1.0 - isTwo; // 奇数列目なら1.0
    p.y += isTwo * 0.5; // 偶数列目を0.5ずらす
    float2 rectUV = frac(p); // 四角形タイル
    float2 grid = floor(p); // 四角形グリッド
    p = frac(p) - 0.5;
    float2 s = sign(p); // マス目の右上:(+1, +1) 左上:(-1, +1) 右下:(+1, -1) 左下:(-1, -1)
    p = abs(p); // 上下左右対称にする
            // 六角形タイルとして出力
    _hexagon = abs(max(p.x * 1.5 + p.y, p.y * 2.0) - 1.0);
            
    float isInHex = step(p.x * 1.5 + p.y, 1.0); // 六角形の内側なら1.0
    float isOutHex = 1.0 - isInHex; // 六角形の外側なら1.0
            // 四角形マスのうち、六角形の外側の部分を補正するために使用する値
    float2 grid2 = float2(0, 0);
            // 偶数列目と奇数列目を同時に加工
    grid2 = lerp(
                float2(s.x, +step(0.0, s.y)), // 奇数列目 (isTwo=0.0の場合はこちらを採用)
                float2(s.x, -step(s.y, 0.0)), // 偶数列目 (isTwo=1.0の場合はこちらを採用)
                isTwo) * isOutHex; // 六角形の外側だけ取り出す
            // 六角形の番号として出力
    _hexIndex = grid + grid2;
            // 六角形の座標として出力
    _hexPos = _hexIndex / _scale;
            // 六角形の内側ならrectUV、外側なら4つの六角形のUVを使う
    _hexUV = lerp(rectUV, rectUV - s * float2(1.0, 0.5), isOutHex);
       
}
#endif