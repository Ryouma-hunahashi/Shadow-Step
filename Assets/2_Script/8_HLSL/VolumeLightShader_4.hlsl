#ifndef SAMPLE_VOLUMELIGHT4_INCLUDED
#define SAMPLE_VOLUMELIGHT4_INCLUDED

void _GenerateVolumeLight4_float(
in float _MaxRayLength,// Rayの最大距離（基準値）
in float3 _lightVector,// 光源の方向ベクトル（単位ベクトル）
in float4 _rayStartPos,// 開始点
in float4 _rayEndPos,// 終了点
in float4 _fogParameter,// x:fogの密度、y:スキャッタリングの積算値、z:ミー散乱用の定数,w:ノイズ値
in float4x4 _lightMatrix, // ワールド座標を光源視点でのUV空間座標に変換するための行列
in UnityTexture2D _lightRenderTexture, // 光源の深度テクスチャ
in UnitySamplerState _sampler, // サンプラー
in bool isLight,
out float _volumelight // 最終的なボリュームライト
)
{
    
    if(isLight==true)
    {
        
    
    // テクスチャサンプリングで得た情報を保持する変数
        float4 _sampleData;
    // スクリーン座標
        float4 _sampleScreenPos;
    // uv
        float2 _uv;
    // レイマーチングのベクトル
        float3 _rayVector = _rayEndPos.xyz - _rayStartPos.xyz;
    // レイマーチングの単位ベクトル
        float3 _rayVectorNormalize = normalize(_rayVector);
    // サンプリング回数でベクトルを割って、ステップ距離を求める
        float _rayStep = length(_rayVector) / 50.0f;
    // 現在のサンプル座標を保持する変数
        float4 _sampleWorldPos = _rayStartPos;
    // 視線ベクトルと光源ベクトルの内積(rayの方向ベクトルは逆にする可能性あり)
        float _dotA = dot(normalize(-_rayVector), _lightVector);
    // 粒子判定の合計値
        float _sumDistance = 0;
    // 現在のRayの進行距離
        float _currentDistance = 0;
    
    // ライティングの計算に使用する変数
        float _pi = 4.0f * 3.1416f;
        float work1 = ((1 - _fogParameter.z) * (1 - _fogParameter.z)) / _pi;
        float work2 = 1 + _fogParameter.z * _fogParameter.z;
        float work3 = 2 * _fogParameter.z;
    // Rayの距離が長いほどサンプルの影響を大きくする（影響が大きすぎるときは定数倍などで要調整）
        float work4 = _rayStep / _MaxRayLength;
        float work5;

        _volumelight = 0;
    // ノイズを使用して開始位置をずらす
    //_currentDistance = (_fogParameter.w - 0.5f)*2.0f;
    
    // ここからループ処理開始=================================================================================================================
    
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    
            // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }
    // 次のサンプル座標へ移動
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // 光源からみたサンプル座標のスクリーン座標を求める
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv変数に代入
        _uv = _sampleScreenPos.xy;
    // 座標が光源範囲内か判定する
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // 深度テクスチャからサンプリングを実行
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // 取得した深度値を比較する
                    if (_sampleData.r - _sampleScreenPos.z <= 0.0001f)
                    {
                        //work5 = _currentDistance / _MaxRayLength;
                    //work5 = exp(work5 * work5 * _fogParameter.x);
                        _sumDistance += _rayStep /** work5*/;
                    //_volumelight += (work1 / pow(work2 - work3 * _dotA, 1.5f)) * _fogParameter.y * work4 / work5;
                     //_volumelight += ((1 - _g) * (1 - _g)) / _pi / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)/* * _sampleScreenPos.z*/;
                    }
                }
            }
        }


        
    //_volumelight = _sumDistance * (work1 / pow(work2 - work3 * _dotA, 1.5f))  * _fogParameter.w;
        _volumelight = _sumDistance * (work1 / (work2 - work3 * _dotA) * (work2 - work3 * _dotA) * _fogParameter.w);
    //_volumelight = pow(_volumelight, 6.0f) * _fogParameter.y;
    //_volumelight /= 6.0f;
    }
    else
    {
        _volumelight = 0;
    }
}


#endif