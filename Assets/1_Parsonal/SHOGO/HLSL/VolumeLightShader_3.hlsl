
#ifndef SAMPLE_VOLUMELIGHT3_INCLUDED
#define SAMPLE_VOLUMELIGHT3_INCLUDED
void _GenerateVolumeLight3_float(
in float3 _vertexWorldPos, // 頂点のワールド座標
in float3 _cameraWorldPos, // メインカメラのワールド座標
in float3 _lightWorldPos, // 光源のワールド座標
in float3 _forwardVector,// 
in float3 _rightVector,
in float3 _upVector,
in float3 _lightParameter, // far,near,size
out float4 _rayStartPos,
out float4 _rayEndPos
)
{
    _rayStartPos.xyz = _cameraWorldPos;
    _rayEndPos.xyz = _vertexWorldPos;
    _rayStartPos.w = 1;
    _rayEndPos.w = 1;
    int posCnt = 0;// 発見した交点の数
    // 面の座標
    float3 _faceCenter;
    // 面の法線
    float3 _faceNormal;
    
    // 面の頂点
    float3 _facePos[8] = {
        // 奥・左・上
        { _lightWorldPos + _forwardVector * _lightParameter.x - _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // 奥・左・下
        { _lightWorldPos + _forwardVector * _lightParameter.x - _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // 奥・右・下
        { _lightWorldPos + _forwardVector * _lightParameter.x + _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // 奥・右・上
        { _lightWorldPos + _forwardVector * _lightParameter.x + _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // 手前・左・上
        { _lightWorldPos + _forwardVector * _lightParameter.y - _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // 手前・左・下
        { _lightWorldPos + _forwardVector * _lightParameter.y - _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // 手前・右・下
        { _lightWorldPos + _forwardVector * _lightParameter.y + _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // 手前・右・上
        { _lightWorldPos + _forwardVector * _lightParameter.y + _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
    };
    // 内積①
    float _dotA;
    // 内積②
    float _dotB;
    // 内積③
    float _dotC;
    // 内積④
    float _dotD; 
    // 外積①
    float3 _crossA;
    // 交点の座標
    float3 _intersectionPos;
    float3 _arrayRayPos[3];
    // 線分①
    float3 _lineA;
    // 線分②
    float3 _lineB;
    // 面①の判定(0,1,2,3)
    _faceCenter = _lightWorldPos + _forwardVector * _lightParameter.x;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _forwardVector);
    _dotB = dot(_lineB, _forwardVector);
    // Rayが無限平面と交差しているか判別する
    if(_dotA*_dotB<0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[1] - _facePos[0], _intersectionPos - _facePos[0]);
        _dotA = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[2] - _facePos[1], _intersectionPos - _facePos[1]);
        _dotB = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[3] - _facePos[2], _intersectionPos - _facePos[2]);
        _dotC = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[0] - _facePos[3], _intersectionPos - _facePos[3]);
        _dotD = dot(_forwardVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    // 面②の判定(4,5,6,7)
    _faceCenter = _lightWorldPos + _forwardVector * _lightParameter.y;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, -_forwardVector);
    _dotB = dot(_lineB, -_forwardVector);
    // Rayが無限平面と交差しているか判別する
    if (_dotA * _dotB < 0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[5] - _facePos[4], _intersectionPos - _facePos[4]);
        _dotA = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[6] - _facePos[5], _intersectionPos - _facePos[5]);
        _dotB = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[7] - _facePos[6], _intersectionPos - _facePos[6]);
        _dotC = dot(_forwardVector, _crossA);
        _crossA = cross(_facePos[4] - _facePos[7], _intersectionPos - _facePos[7]);
        _dotD = dot(_forwardVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    // 面③の判定(0,1,5,4)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector - _rightVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _rightVector);
    _dotB = dot(_lineB, _rightVector);
    // Rayが無限平面と交差しているか判別する
    if (_dotA * _dotB < 0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[1] - _facePos[0], _intersectionPos - _facePos[0]);
        _dotA = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[5] - _facePos[1], _intersectionPos - _facePos[1]);
        _dotB = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[4] - _facePos[5], _intersectionPos - _facePos[5]);
        _dotC = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[0] - _facePos[4], _intersectionPos - _facePos[4]);
        _dotD = dot(_rightVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    // 面④の判定(3,2,6,7)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector + _rightVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _rightVector);
    _dotB = dot(_lineB, _rightVector);
    // Rayが無限平面と交差しているか判別する
    if (_dotA * _dotB < 0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[2] - _facePos[3], _intersectionPos - _facePos[3]);
        _dotA = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[6] - _facePos[2], _intersectionPos - _facePos[2]);
        _dotB = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[7] - _facePos[6], _intersectionPos - _facePos[6]);
        _dotC = dot(_rightVector, _crossA);
        _crossA = cross(_facePos[3] - _facePos[7], _intersectionPos - _facePos[7]);
        _dotD = dot(_rightVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    // 面⑤の判定(4,0,3,7)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector + _upVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _upVector);
    _dotB = dot(_lineB, _upVector);
    // Rayが無限平面と交差しているか判別する
    if (_dotA * _dotB < 0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[0] - _facePos[4], _intersectionPos - _facePos[4]);
        _dotA = dot(_upVector, _crossA);
        _crossA = cross(_facePos[3] - _facePos[0], _intersectionPos - _facePos[0]);
        _dotB = dot(_upVector, _crossA);
        _crossA = cross(_facePos[7] - _facePos[3], _intersectionPos - _facePos[3]);
        _dotC = dot(_upVector, _crossA);
        _crossA = cross(_facePos[4] - _facePos[7], _intersectionPos - _facePos[7]);
        _dotD = dot(_upVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    // 面⑥の判定(5,1,2,6)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector - _upVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _upVector);
    _dotB = dot(_lineB, _upVector);
    // Rayが無限平面と交差しているか判別する
    if (_dotA * _dotB < 0)
    {
        // 交点を求める
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ある辺のベクトルと、頂点と交点を結ぶベクトルで外積を求め、法線との内積を取得し、同じ方向になっているかを確かめる
        _crossA = cross(_facePos[1] - _facePos[5], _intersectionPos - _facePos[5]);
        _dotA = dot(_upVector, _crossA);
        _crossA = cross(_facePos[2] - _facePos[1], _intersectionPos - _facePos[1]);
        _dotB = dot(_upVector, _crossA);
        _crossA = cross(_facePos[6] - _facePos[2], _intersectionPos - _facePos[2]);
        _dotC = dot(_upVector, _crossA);
        _crossA = cross(_facePos[5] - _facePos[6], _intersectionPos - _facePos[6]);
        _dotD = dot(_upVector, _crossA);
        if ((_dotA > 0) && (_dotB > 0) && (_dotC > 0) && (_dotD > 0))
        {
            _arrayRayPos[posCnt] = _intersectionPos;
            posCnt++;
        }
    }
    
    // 交点の数によって開始・終了点を変更
    if(posCnt==1)
    {
        _rayStartPos.xyz = _arrayRayPos[0];
    }
    else if(posCnt==2)
    {
        if(_arrayRayPos[0].y<_arrayRayPos[1].y)
        {
            _rayStartPos.xyz = _arrayRayPos[1];
            _rayEndPos.xyz = _arrayRayPos[0];
        }
        else
        {
            _rayStartPos.xyz = _arrayRayPos[0];
            _rayEndPos.xyz = _arrayRayPos[1];
        }
    }


}

#endif