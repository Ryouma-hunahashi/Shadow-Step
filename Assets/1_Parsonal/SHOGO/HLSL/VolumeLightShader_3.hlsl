
#ifndef SAMPLE_VOLUMELIGHT3_INCLUDED
#define SAMPLE_VOLUMELIGHT3_INCLUDED
void _GenerateVolumeLight3_float(
in float3 _vertexWorldPos, // ���_�̃��[���h���W
in float3 _cameraWorldPos, // ���C���J�����̃��[���h���W
in float3 _lightWorldPos, // �����̃��[���h���W
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
    int posCnt = 0;// ����������_�̐�
    // �ʂ̍��W
    float3 _faceCenter;
    // �ʂ̖@��
    float3 _faceNormal;
    
    // �ʂ̒��_
    float3 _facePos[8] = {
        // ���E���E��
        { _lightWorldPos + _forwardVector * _lightParameter.x - _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // ���E���E��
        { _lightWorldPos + _forwardVector * _lightParameter.x - _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // ���E�E�E��
        { _lightWorldPos + _forwardVector * _lightParameter.x + _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // ���E�E�E��
        { _lightWorldPos + _forwardVector * _lightParameter.x + _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // ��O�E���E��
        { _lightWorldPos + _forwardVector * _lightParameter.y - _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
        // ��O�E���E��
        { _lightWorldPos + _forwardVector * _lightParameter.y - _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // ��O�E�E�E��
        { _lightWorldPos + _forwardVector * _lightParameter.y + _rightVector * _lightParameter.z / 2.0f - _upVector * _lightParameter.z / 2.0f },
        // ��O�E�E�E��
        { _lightWorldPos + _forwardVector * _lightParameter.y + _rightVector * _lightParameter.z / 2.0f + _upVector * _lightParameter.z / 2.0f },
    };
    // ���χ@
    float _dotA;
    // ���χA
    float _dotB;
    // ���χB
    float _dotC;
    // ���χC
    float _dotD; 
    // �O�χ@
    float3 _crossA;
    // ��_�̍��W
    float3 _intersectionPos;
    float3 _arrayRayPos[3];
    // �����@
    float3 _lineA;
    // �����A
    float3 _lineB;
    // �ʇ@�̔���(0,1,2,3)
    _faceCenter = _lightWorldPos + _forwardVector * _lightParameter.x;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _forwardVector);
    _dotB = dot(_lineB, _forwardVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if(_dotA*_dotB<0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    // �ʇA�̔���(4,5,6,7)
    _faceCenter = _lightWorldPos + _forwardVector * _lightParameter.y;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, -_forwardVector);
    _dotB = dot(_lineB, -_forwardVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if (_dotA * _dotB < 0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    // �ʇB�̔���(0,1,5,4)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector - _rightVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _rightVector);
    _dotB = dot(_lineB, _rightVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if (_dotA * _dotB < 0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    // �ʇC�̔���(3,2,6,7)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector + _rightVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _rightVector);
    _dotB = dot(_lineB, _rightVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if (_dotA * _dotB < 0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    // �ʇD�̔���(4,0,3,7)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector + _upVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _upVector);
    _dotB = dot(_lineB, _upVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if (_dotA * _dotB < 0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    // �ʇE�̔���(5,1,2,6)
    _faceCenter = _lightWorldPos + (_lightParameter.x - _lightParameter.y) / 2.0f * _forwardVector - _upVector * _lightParameter.z / 2.0f;
    _lineA = _cameraWorldPos - _faceCenter;
    _lineB = _vertexWorldPos - _faceCenter;
    _dotA = dot(_lineA, _upVector);
    _dotB = dot(_lineB, _upVector);
    // Ray���������ʂƌ������Ă��邩���ʂ���
    if (_dotA * _dotB < 0)
    {
        // ��_�����߂�
        float m = abs(_dotA);
        float n = abs(_dotB);
        _intersectionPos = (_cameraWorldPos * n + _vertexWorldPos * m) / (m + n);
       // ����ӂ̃x�N�g���ƁA���_�ƌ�_�����ԃx�N�g���ŊO�ς����߁A�@���Ƃ̓��ς��擾���A���������ɂȂ��Ă��邩���m���߂�
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
    
    // ��_�̐��ɂ���ĊJ�n�E�I���_��ύX
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