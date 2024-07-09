
#ifndef SAMPLE_VOLUMELIGHT2_INCLUDED
#define SAMPLE_VOLUMELIGHT2_INCLUDED
// _Sample�֐�����T���v���񐔂Ƃ�Ray�̒P�ʃx�N�g�����擾���A���C�g�̃e�N�X�`������T���v�����J��Ԃ�
void _GenerateVolumeLight2_float(
in float _rayLength, // ���C�}�[�`���O�P��Ői�ދ���
in float _g, // �~�[�U���̌v�Z�Ɏg�p����萔
in float4 _vertexWorldPos, // ���_�̃��[���h���W
in float4 _cameraWorldPos, // ���C���J�����̃��[���h���W
in float4 _lightWorldPos, // �����̃��[���h���W
in float4 _fogParameter, // 
in float4x4 _lightMatrix, // ���[���h���W���������_�ł�UV��ԍ��W�ɕϊ����邽�߂̍s��
in UnityTexture2D _lightRenderTexture, // �����̐[�x�e�N�X�`��
in UnitySamplerState _sampler, // �T���v���[
in float4 _lightVector,
out float _volumelight // �ŏI�I�ȃ{�����[�����C�g
)
{
    // �ϐ��錾�E������==================================================================================
    _cameraWorldPos.xyz += _fogParameter.z;
    // �J�������璸�_�Ɍ������x�N�g���i�x�N�g��A�j
    float3 _fromCameraToVertexVector = _vertexWorldPos.xyz - _cameraWorldPos.xyz;
    // �������璸�_�Ɍ������x�N�g���i�x�N�g��B�j
    //float3 _fromLightToVertexVector = _vertexWorldPos.xyz - _lightWorldPos.xyz;
    float3 _fromLightToVertexVector = _lightVector.xyz;
    // RayMarching�̌v�Z�Ɏg�p����x�N�g���i�x�N�g��C�j
    float3 _raymarchingVector = _fromCameraToVertexVector / _rayLength;
    // �x�N�g��A�̑傫��
    float _lengthFromCameraToVertexVector = length(_fromCameraToVertexVector);
    // �x�N�g��B�̑傫��
    float _lengthFromLightToVertexVector = length(_fromLightToVertexVector);
    // �x�N�g��A�𐳋K����������
    float3 _normalizeFromCameraToVertexVector = normalize(_fromCameraToVertexVector);
    // �x�N�g��B�𐳋K����������
    float3 _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
    // �x�N�g��A�̋t�x�N�g���𐳋K����������
    float3 _normalizeFromCameraToVertexVector2 = normalize(-(_fromCameraToVertexVector));
    // �x�N�g��A�̋t�x�N�g���ƃx�N�g��B�̓���
    //float _dotA = dot(mul(_fromCameraToVertexVector, -1.0f), _fromLightToVertexVector);
    float _dotA = dot(_normalizeFromCameraToVertexVector2, _normalizeFromLightToVertexVector);


    // ���݂̐i�s����
    float _currentDistance = 0;
    // �T���v���Ɏg�p����UV
    float2 _uv;
    // �T���v���Ɏg�p���郏�[���h���W
    float4 _sampleWorldPos;
    // �T���v���Ɏg�p����X�N���[�����W
    float4 _sampleScreenPos;
    // �e�N�X�`������f�[�^���󂯎��ϐ�
    float4 _sampleData;
    // Ray�̍ő勗��
    float _MaxRayLength = 50;
    // �ŏI���ʂɎg�p���郉�C�g�̏�����
    _volumelight = 0;
    // �v�Z�p�ϐ�
    // �~�[�U���̌v�Z�Ɏg���ϐ�
    float _pi = 4.0f * 3.1416f;
    float work1 = ((1 - _g) * (1 - _g)) / _pi;
    float work2 = 1 + _g * _g;
    float work3 = 2 * _g;
    float work4 = _rayLength / _MaxRayLength;
    float work5;
    
     // Ray��i�߂�
    _currentDistance += _rayLength;
    
    //[unroll(100)]
    //for (int i = 0; i < 100;i++)
    //{

    //    // �T���v���ʒu�̍X�V
    //    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    //    _sampleWorldPos.w = 1;
    //    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    //    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
    //    // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
    //                // �[�x�e�N�X�`������T���v�����O�����s
    //                _sampleData=SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
    //                // �擾�����[�x�l���r����
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
    //    // Ray��i�߂�
    //    _currentDistance += _rayLength;
    //    // �I������
    //    if(_currentDistance>_lengthFromCameraToVertexVector)
    //    {
    //        break;
    //    }
    //}
             // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                 // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
             // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
             // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
             // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
             // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
                // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength; // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;
            // �T���v���ʒu�̍X�V
    _sampleWorldPos.xyz = _cameraWorldPos.xyz + _currentDistance * _normalizeFromCameraToVertexVector;
    _sampleWorldPos.w = 1;
    _fromLightToVertexVector = _sampleWorldPos.xyz - _lightWorldPos.xyz;
    _normalizeFromLightToVertexVector = normalize(_fromLightToVertexVector);
        // �������猩���T���v���ʒu�̃X�N���[�����W�����߂�
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
                    // �[�x�e�N�X�`������T���v�����O�����s
                _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                    // �擾�����[�x�l���r����
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
        // Ray��i�߂�
    _currentDistance += _rayLength;


 


}

#endif