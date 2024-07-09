
#ifndef SAMPLE_VOLUMELIGHT2_INCLUDED
#define SAMPLE_VOLUMELIGHT2_INCLUDED
// _Sample関数からサンプル回数ととRayの単位ベクトルを取得し、ライトのテクスチャからサンプルを繰り返す
void _GenerateVolumeLight2_float(
in float _rayLength, // レイマーチング１回で進む距離
in float _g, // ミー散乱の計算に使用する定数
in float4 _vertexWorldPos, // 頂点のワールド座標
in float4 _cameraWorldPos, // メインカメラのワールド座標
in float4 _lightWorldPos, // 光源のワールド座標
in float4 _fogParameter, // 
in float4x4 _lightMatrix, // ワールド座標を光源視点でのUV空間座標に変換するための行列
in UnityTexture2D _lightRenderTexture, // 光源の深度テクスチャ
in UnitySamplerState _sampler, // サンプラー
in float4 _lightVector,
out float _volumelight // 最終的なボリュームライト
)
{
    // 変数宣言・初期化==================================================================================
    _cameraWorldPos.xyz += _fogParameter.z;
    // カメラから頂点に向かうベクトル（ベクトルA）
    float3 _fromCameraToVertexVector = _vertexWorldPos.xyz - _cameraWorldPos.xyz;
    // 光源から頂点に向かうベクトル（ベクトルB）
    //float3 _fromLightToVertexVector = _vertexWorldPos.xyz - _lightWorldPos.xyz;
    float3 _fromLightToVertexVector = _lightVector.xyz;
    // RayMarchingの計算に使用するベクトル（ベクトルC）
    float3 _raymarchingVector = _fromCameraToVertexVector / _rayLength;
    // ベクトルAの大きさ
    float _lengthFromCameraToVertexVector = length(_fromCameraToVertexVector);
    // ベクトルBの大きさ
    float _lengthFromLightToVertexVector = length(_fromLightToVertexVector);
    // ベクトルAを正規化したもの
    float3 _normalizeFromCameraToVertexVector = normalize(_fromCameraToVertexVector);
    // ベクトルBを正規化したもの
    float3 _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
    // ベクトルAの逆ベクトルを正規化したもの
    float3 _normalizeFromCameraToVertexVector2 = normalize(-(_fromCameraToVertexVector));
    // ベクトルAの逆ベクトルとベクトルBの内積
    //float _dotA = dot(mul(_fromCameraToVertexVector, -1.0f), _fromLightToVertexVector);
    float _dotA = dot(_normalizeFromCameraToVertexVector2, _normalizeFromLightToVertexVector);


    // 現在の進行距離
    float _currentDistance = 0;
    // サンプルに使用するUV
    float2 _uv;
    // サンプルに使用するワールド座標
    float4 _sampleWorldPos;
    // サンプルに使用するスクリーン座標
    float4 _sampleScreenPos;
    // テクスチャからデータを受け取る変数
    float4 _sampleData;
    // Rayの最大距離
    float _MaxRayLength = 50;
    // 最終結果に使用するライトの初期化
    _volumelight = 0;
    // 計算用変数
    // ミー散乱の計算に使う変数
    float _pi = 4.0f * 3.1416f;
    float work1 = ((1 - _g) * (1 - _g)) / _pi;
    float work2 = 1 + _g * _g;
    float work3 = 2 * _g;
    float work4 = _rayLength / _MaxRayLength;
    float work5;
    
     // Rayを進める
    _currentDistance += _rayLength;
    
    //[unroll(100)]
    //for (int i = 0; i < 100;i++)
    //{

    //    // サンプル位置の更新
    //    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    //    _sampleWorldPos.w = 1;
    //    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    //    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
    //    // 光源から見たサンプル位置のスクリーン座標を求める
    //    //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    //    _sampleScreenPos = mul(_lightMatrix,_sampleWorldPos);
    //    //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    //    _uv = _sampleScreenPos.xy;
    //    //_sampleScreenPos.z /= _sampleScreenPos.w;
    //    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    //    {
    //        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
    //        {
    //            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
    //            {
    //                // 深度テクスチャからサンプリングを実行
    //                _sampleData=SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
    //                // 取得した深度値を比較する
    //                if(_sampleData.r<=_sampleScreenPos.z)
    //                {
    //                    work5 = _currentDistance / _MaxRayLength;
    //                    work5 = exp(work5 * work5 * _fogParameter.x);
    //                    //work5 = 1;
    //                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5 * _sampleScreenPos.z;
    //                    //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
    //                }
    //            }
    //        }
    //    }
    //    // Rayを進める
    //    _currentDistance += _rayLength;
    //    // 終了判定
    //    if(_currentDistance>_lengthFromCameraToVertexVector)
    //    {
    //        break;
    //    }
    //}
             // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                 // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
             // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
             // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
             // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
             // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
                // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength; // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;
            // サンプル位置の更新
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // 光源から見たサンプル位置のスクリーン座標を求める
        //_sampleScreenPos = mul(_sampleWorldPos, _lightMatrix);
    _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
        //_uv = (_sampleScreenPos.xy / _sampleScreenPos.z);
    _uv = _sampleScreenPos.xy;
        //_sampleScreenPos.z /= _sampleScreenPos.w;
    if ((_uv.x <= 1.0f) && (_uv.x >= 0.0f))
    {
        if ((_uv.y <= 1.0f) && (_uv.y > 0.0f))
        {
            if ((_sampleScreenPos.z <= 1.0f) && (_sampleScreenPos.z >= 0.0f))
            {
                    // 深度テクスチャからサンプリングを実行
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // 取得した深度値を比較する
                if (_sampleData.r <= _sampleScreenPos.z)
                {
                    work5 = _currentDistance / _MaxRayLength;
                    work5 = exp(work5 * work5 * _fogParameter.x);
                        //work5 = 1;
                    _volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 * work5;
                        //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                }
            }
        }
    }
        // Rayを進める
    _currentDistance += _rayLength;


 


}

#endif