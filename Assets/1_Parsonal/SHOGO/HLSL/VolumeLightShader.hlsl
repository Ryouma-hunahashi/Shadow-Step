//#ifndef CUSTOM_LIGHTING_INCLUDEDHLSL
//#define CUSTOM_LIGHTING_INCLUDED
#ifndef SAMPLE_VOLUMELIGHT_INCLUDED
#define SAMPLE_VOLUMELIGHT_INCLUDED
// _Sample関数からサンプル回数ととRayの単位ベクトルを取得し、ライトのテクスチャからサンプルを繰り返す
void _GenerateVolumeLight_float(
in float _sampleCount, // サンプル回数
in float _g, // ミー散乱の計算に使用する定数
in float _raySpeed, // Rayの進行速度
in float3 _lightVector, // 光源の単位ベクトル
in float3 _rayVector, // Rayの単位ベクトル
in float4 _worldSamplePos, // ワールド座標でのサンプル座標
in float4x4 _lightMatrix, // ワールド座標を光源視点でのUV空間座標に変換するための行列
in UnityTexture2D _lightRenderTexture, // 光源の深度テクスチャ
in UnitySamplerState _sampler, // サンプラー
in float4 _offset,
out float _volumeLight // 最終的にピクセルに加算するライトの強さ
)
{
    _volumeLight = 0;
    // 光源ベクトルとRayベクトルの内積を取得
    float _dotA = dot(mul(_rayVector, -1.0f), _lightVector);
    // 計算に使用する円周率（4π）
    float p = 4.0f * 3.14f;
    // サンプリングに使用するためのUVを代入するための変数
    float2 uv;
    // rayの進行距離を取得
    float3 moveDistance = mul(_rayVector, _raySpeed);
    //moveDistance.x = _rayVector.x * _raySpeed;
    //moveDistance.y = _rayVector.y * _raySpeed;
    //moveDistance.z = _rayVector.z * _raySpeed;
    // 深度テクスチャから取得したデータ
    float4 sampleData;
    // スクリーン空間でのサンプル座標
    float4 _screenSamplePos;
    // 
    float4 _worldSampleStartPos=_worldSamplePos;
    // _sampleCountの数だけサンプリングを実行
    [unroll(100)]for (int i = 0; i < 100; i++)
    {
        
        // サンプルを行う座標が光源の範囲内に存在するかどうかを判別する
        // 座標をワールド座標から光源視点のUV空間座標に変換する
        //_screenSamplePos = mul(_worldSamplePos, _lightMatrix);
        _screenSamplePos = mul(_lightMatrix,_worldSamplePos);
        _screenSamplePos.x = (_screenSamplePos.x / _screenSamplePos.w) * _offset.x + _offset.y;
        _screenSamplePos.y = (_screenSamplePos.y / _screenSamplePos.w) * _offset.z + _offset.w;
        _screenSamplePos.z /= _screenSamplePos.w;
        // 変換した座標のX,Yの値が０～１の範囲に収まっているかを確認する
        if (((_screenSamplePos.x <= 1.0f) && (_screenSamplePos.x >= 0.0f) && (_screenSamplePos.y <= 1.0f) && (_screenSamplePos.y >= 0.0f) && (_screenSamplePos.z <= 1.0f) && (_screenSamplePos.z >= 0.0f)))
        {
            
            // UV空間座標に変換した数値のXとYの値ををfloat2変数に代入
            uv.x = _screenSamplePos.x/*/_screenSamplePos.w*/;
            uv.y = _screenSamplePos.y/*/_screenSamplePos.w*/;
            // 変換した座標でサンプリングを行う
            sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, uv);
            // 深度値を比較する
            if (_screenSamplePos.z  > sampleData.x-0.0001f)
            {
                
                _volumeLight += ((1 - _g) * (1 - _g)) / p / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)*_screenSamplePos.z;
                //_volumeLight += (1.0f / p) * ((1 - _g * _g) / pow(1 + _g * _g - 2 * _g * _dotA, 1.5f)) * _screenSamplePos.z * _screenSamplePos.z;
                //_volumeLight += 0.1f;
            }
        }
        
        // 次のサンプル座標に移動
        //_worldSamplePos.x += moveDistance.x;
        //_worldSamplePos.y += moveDistance.y;
        //_worldSamplePos.z += moveDistance.z;
        _worldSamplePos.x = moveDistance.x * i + _worldSampleStartPos.x;
        _worldSamplePos.y = moveDistance.y * i + _worldSampleStartPos.y;
        _worldSamplePos.z = moveDistance.z * i + _worldSampleStartPos.z;
        //_worldSamplePos.x = _rayVector.x * i * _sampleCount + _worldSampleStartPos.x;
        //_worldSamplePos.y = _rayVector.y * i * _sampleCount + _worldSampleStartPos.y;
        //_worldSamplePos.z = _rayVector.z * i * _sampleCount + _worldSampleStartPos.z;
        //if (i > _sampleCount)
        //{
        //    break;
        //}
    }
}

#endif