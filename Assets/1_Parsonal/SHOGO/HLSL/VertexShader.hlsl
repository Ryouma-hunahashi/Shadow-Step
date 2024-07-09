//#ifndef CUSTOM_LIGHTING_INCLUDEDHLSL
//#define CUSTOM_LIGHTING_INCLUDED
#ifndef SAMPLE_OUTLINE_INCLUDED
#define SAMPLE_OUTLINE_INCLUDED
// 深度テクスチャからサンプリングを複数回行い、その結果をピクセルに加算するHLSLコード
//①メインカメラの座標と頂点座標の距離を求める
//②
//サンプリング方式が距離の場合
// ①で求めた距離/サンプリング距離でサンプリング回数を決定
//サンプリング方式が回数の場合
// ①で求めた距離/サンプリング回数でサンプリング距離を決定
//③
// ②で求めたサンプリング回数をもとにループ処理を実行
// カメラからサンプリングを行い光が当たっているかどうかを判別する
// 当たっていないときは0,当たっているときはout用の変数に計算した数値を加算していく
// 粒子のライティングの計算には近似式を用いるものとする
// 
// int サンプリング回数
// float サンプリング距離
// sampler 深度テクスチャ取得に使用するサンプラー
// 
// texture 光源の深度テクスチャ
// matrix 光源視点へのビュー変換行列
// float3 頂点のワールド座標
// out 
// float3 ピクセルに加算する光の量
void _texture_float(UnityTexture2D _texture, float2 _uv, UnitySamplerState _sampler, out float4 _outColor)
{
    _outColor = SAMPLE_TEXTURE2D(_texture, _sampler, _uv);
    
}

// サンプリング回数を決定するための関数
// in float3 カメラのワールド座標
// in float3 頂点のワールド座標
// in float サンプリング１回につきRayが進む距離
// out float サンプリング回数
// out float3 Rayの単位ベクトル
void _Sample_float(
in float3 _cameraPos,
in float3 _vertexPos,
in float _raySpeed,
out float _sampleCount,
out float3 _rayVector
)
{
    // カメラから頂点に向かうベクトルAを求める
    //float3 VectorA = _vertexPos - _cameraPos;
    float3 VectorA = _cameraPos - _vertexPos;
    // ベクトルAの大きさを求める
    //float LengthA = VectorA.x * VectorA.x + VectorA.y * VectorA.y + VectorA.z * VectorA.z;
    float LengthA = length(VectorA);
    // ベクトルAの大きさとRayの進む距離からサンプリング回数を決定する
    _sampleCount = LengthA / _raySpeed;
    //// Rayの単位ベクトルを求める
    _rayVector = normalize(VectorA);
    //_rayVector.x = VectorA.x / LengthA;
    //_rayVector.y = VectorA.y / LengthA;
    //_rayVector.z = VectorA.z / LengthA;
}
#endif