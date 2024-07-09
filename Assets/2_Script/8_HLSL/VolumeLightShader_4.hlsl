#ifndef SAMPLE_VOLUMELIGHT4_INCLUDED
#define SAMPLE_VOLUMELIGHT4_INCLUDED

void _GenerateVolumeLight4_float(
in float _MaxRayLength,// Ray�̍ő勗���i��l�j
in float3 _lightVector,// �����̕����x�N�g���i�P�ʃx�N�g���j
in float4 _rayStartPos,// �J�n�_
in float4 _rayEndPos,// �I���_
in float4 _fogParameter,// x:fog�̖��x�Ay:�X�L���b�^�����O�̐ώZ�l�Az:�~�[�U���p�̒萔,w:�m�C�Y�l
in float4x4 _lightMatrix, // ���[���h���W���������_�ł�UV��ԍ��W�ɕϊ����邽�߂̍s��
in UnityTexture2D _lightRenderTexture, // �����̐[�x�e�N�X�`��
in UnitySamplerState _sampler, // �T���v���[
in bool isLight,
out float _volumelight // �ŏI�I�ȃ{�����[�����C�g
)
{
    
    if(isLight==true)
    {
        
    
    // �e�N�X�`���T���v�����O�œ�������ێ�����ϐ�
        float4 _sampleData;
    // �X�N���[�����W
        float4 _sampleScreenPos;
    // uv
        float2 _uv;
    // ���C�}�[�`���O�̃x�N�g��
        float3 _rayVector = _rayEndPos.xyz - _rayStartPos.xyz;
    // ���C�}�[�`���O�̒P�ʃx�N�g��
        float3 _rayVectorNormalize = normalize(_rayVector);
    // �T���v�����O�񐔂Ńx�N�g���������āA�X�e�b�v���������߂�
        float _rayStep = length(_rayVector) / 50.0f;
    // ���݂̃T���v�����W��ێ�����ϐ�
        float4 _sampleWorldPos = _rayStartPos;
    // �����x�N�g���ƌ����x�N�g���̓���(ray�̕����x�N�g���͋t�ɂ���\������)
        float _dotA = dot(normalize(-_rayVector), _lightVector);
    // ���q����̍��v�l
        float _sumDistance = 0;
    // ���݂�Ray�̐i�s����
        float _currentDistance = 0;
    
    // ���C�e�B���O�̌v�Z�Ɏg�p����ϐ�
        float _pi = 4.0f * 3.1416f;
        float work1 = ((1 - _fogParameter.z) * (1 - _fogParameter.z)) / _pi;
        float work2 = 1 + _fogParameter.z * _fogParameter.z;
        float work3 = 2 * _fogParameter.z;
    // Ray�̋����������قǃT���v���̉e����傫������i�e�����傫������Ƃ��͒萔�{�Ȃǂŗv�����j
        float work4 = _rayStep / _MaxRayLength;
        float work5;

        _volumelight = 0;
    // �m�C�Y���g�p���ĊJ�n�ʒu�����炷
    //_currentDistance = (_fogParameter.w - 0.5f)*2.0f;
    
    // �������烋�[�v�����J�n=================================================================================================================
    
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    
            // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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
    // ���̃T���v�����W�ֈړ�
        _currentDistance += _rayStep;
        _sampleWorldPos.xyz = _rayStartPos.xyz + _currentDistance * _rayVectorNormalize;

    // ��������݂��T���v�����W�̃X�N���[�����W�����߂�
        _sampleScreenPos = mul(_lightMatrix, _sampleWorldPos);
    // uv�ϐ��ɑ��
        _uv = _sampleScreenPos.xy;
    // ���W�������͈͓������肷��
        if ((_uv.x - 1.0f <= 0.0001f) && (_uv.x >= -0.0001f))
        {
            if ((_uv.y - 1.0f <= 0.0001f) && (_uv.y >= -0.0001f))
            {
                if ((_sampleScreenPos.z - 1.0f <= 0.0001f) && (_sampleScreenPos.z > -0.0001f))
                {
                // �[�x�e�N�X�`������T���v�����O�����s
                    _sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, _uv);
                // �擾�����[�x�l���r����
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