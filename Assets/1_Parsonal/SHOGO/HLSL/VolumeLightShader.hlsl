//#ifndef CUSTOM_LIGHTING_INCLUDEDHLSL
//#define CUSTOM_LIGHTING_INCLUDED
#ifndef SAMPLE_VOLUMELIGHT_INCLUDED
#define SAMPLE_VOLUMELIGHT_INCLUDED
// _Sample�֐�����T���v���񐔂Ƃ�Ray�̒P�ʃx�N�g�����擾���A���C�g�̃e�N�X�`������T���v�����J��Ԃ�
void _GenerateVolumeLight_float(
in float _sampleCount, // �T���v����
in float _g, // �~�[�U���̌v�Z�Ɏg�p����萔
in float _raySpeed, // Ray�̐i�s���x
in float3 _lightVector, // �����̒P�ʃx�N�g��
in float3 _rayVector, // Ray�̒P�ʃx�N�g��
in float4 _worldSamplePos, // ���[���h���W�ł̃T���v�����W
in float4x4 _lightMatrix, // ���[���h���W���������_�ł�UV��ԍ��W�ɕϊ����邽�߂̍s��
in UnityTexture2D _lightRenderTexture, // �����̐[�x�e�N�X�`��
in UnitySamplerState _sampler, // �T���v���[
in float4 _offset,
out float _volumeLight // �ŏI�I�Ƀs�N�Z���ɉ��Z���郉�C�g�̋���
)
{
    _volumeLight = 0;
    // �����x�N�g����Ray�x�N�g���̓��ς��擾
    float _dotA = dot(mul(_rayVector, -1.0f), _lightVector);
    // �v�Z�Ɏg�p����~�����i4�΁j
    float p = 4.0f * 3.14f;
    // �T���v�����O�Ɏg�p���邽�߂�UV�������邽�߂̕ϐ�
    float2 uv;
    // ray�̐i�s�������擾
    float3 moveDistance = mul(_rayVector, _raySpeed);
    //moveDistance.x = _rayVector.x * _raySpeed;
    //moveDistance.y = _rayVector.y * _raySpeed;
    //moveDistance.z = _rayVector.z * _raySpeed;
    // �[�x�e�N�X�`������擾�����f�[�^
    float4 sampleData;
    // �X�N���[����Ԃł̃T���v�����W
    float4 _screenSamplePos;
    // 
    float4 _worldSampleStartPos=_worldSamplePos;
    // _sampleCount�̐������T���v�����O�����s
    [unroll(100)]for (int i = 0; i < 100; i++)
    {
        
        // �T���v�����s�����W�������͈͓̔��ɑ��݂��邩�ǂ����𔻕ʂ���
        // ���W�����[���h���W����������_��UV��ԍ��W�ɕϊ�����
        //_screenSamplePos = mul(_worldSamplePos, _lightMatrix);
        _screenSamplePos = mul(_lightMatrix,_worldSamplePos);
        _screenSamplePos.x = (_screenSamplePos.x / _screenSamplePos.w) * _offset.x + _offset.y;
        _screenSamplePos.y = (_screenSamplePos.y / _screenSamplePos.w) * _offset.z + _offset.w;
        _screenSamplePos.z /= _screenSamplePos.w;
        // �ϊ��������W��X,Y�̒l���O�`�P�͈̔͂Ɏ��܂��Ă��邩���m�F����
        if (((_screenSamplePos.x <= 1.0f) && (_screenSamplePos.x >= 0.0f) && (_screenSamplePos.y <= 1.0f) && (_screenSamplePos.y >= 0.0f) && (_screenSamplePos.z <= 1.0f) && (_screenSamplePos.z >= 0.0f)))
        {
            
            // UV��ԍ��W�ɕϊ��������l��X��Y�̒l����float2�ϐ��ɑ��
            uv.x = _screenSamplePos.x/*/_screenSamplePos.w*/;
            uv.y = _screenSamplePos.y/*/_screenSamplePos.w*/;
            // �ϊ��������W�ŃT���v�����O���s��
            sampleData = SAMPLE_TEXTURE2D(_lightRenderTexture, _sampler, uv);
            // �[�x�l���r����
            if (_screenSamplePos.z  > sampleData.x-0.0001f)
            {
                
                _volumeLight += ((1 - _g) * (1 - _g)) / p / pow((1 + _g * _g) - 2 * _g * _dotA, 1.5f)*_screenSamplePos.z;
                //_volumeLight += (1.0f / p) * ((1 - _g * _g) / pow(1 + _g * _g - 2 * _g * _dotA, 1.5f)) * _screenSamplePos.z * _screenSamplePos.z;
                //_volumeLight += 0.1f;
            }
        }
        
        // ���̃T���v�����W�Ɉړ�
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