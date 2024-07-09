//#ifndef CUSTOM_LIGHTING_INCLUDEDHLSL
//#define CUSTOM_LIGHTING_INCLUDED
#ifndef SAMPLE_OUTLINE_INCLUDED
#define SAMPLE_OUTLINE_INCLUDED
// �[�x�e�N�X�`������T���v�����O�𕡐���s���A���̌��ʂ��s�N�Z���ɉ��Z����HLSL�R�[�h
//�@���C���J�����̍��W�ƒ��_���W�̋��������߂�
//�A
//�T���v�����O�����������̏ꍇ
// �@�ŋ��߂�����/�T���v�����O�����ŃT���v�����O�񐔂�����
//�T���v�����O�������񐔂̏ꍇ
// �@�ŋ��߂�����/�T���v�����O�񐔂ŃT���v�����O����������
//�B
// �A�ŋ��߂��T���v�����O�񐔂����ƂɃ��[�v���������s
// �J��������T���v�����O���s�������������Ă��邩�ǂ����𔻕ʂ���
// �������Ă��Ȃ��Ƃ���0,�������Ă���Ƃ���out�p�̕ϐ��Ɍv�Z�������l�����Z���Ă���
// ���q�̃��C�e�B���O�̌v�Z�ɂ͋ߎ�����p������̂Ƃ���
// 
// int �T���v�����O��
// float �T���v�����O����
// sampler �[�x�e�N�X�`���擾�Ɏg�p����T���v���[
// 
// texture �����̐[�x�e�N�X�`��
// matrix �������_�ւ̃r���[�ϊ��s��
// float3 ���_�̃��[���h���W
// out 
// float3 �s�N�Z���ɉ��Z������̗�
void _texture_float(UnityTexture2D _texture, float2 _uv, UnitySamplerState _sampler, out float4 _outColor)
{
    _outColor = SAMPLE_TEXTURE2D(_texture, _sampler, _uv);
    
}

// �T���v�����O�񐔂����肷�邽�߂̊֐�
// in float3 �J�����̃��[���h���W
// in float3 ���_�̃��[���h���W
// in float �T���v�����O�P��ɂ�Ray���i�ދ���
// out float �T���v�����O��
// out float3 Ray�̒P�ʃx�N�g��
void _Sample_float(
in float3 _cameraPos,
in float3 _vertexPos,
in float _raySpeed,
out float _sampleCount,
out float3 _rayVector
)
{
    // �J�������璸�_�Ɍ������x�N�g��A�����߂�
    //float3 VectorA = _vertexPos - _cameraPos;
    float3 VectorA = _cameraPos - _vertexPos;
    // �x�N�g��A�̑傫�������߂�
    //float LengthA = VectorA.x * VectorA.x + VectorA.y * VectorA.y + VectorA.z * VectorA.z;
    float LengthA = length(VectorA);
    // �x�N�g��A�̑傫����Ray�̐i�ދ�������T���v�����O�񐔂����肷��
    _sampleCount = LengthA / _raySpeed;
    //// Ray�̒P�ʃx�N�g�������߂�
    _rayVector = normalize(VectorA);
    //_rayVector.x = VectorA.x / LengthA;
    //_rayVector.y = VectorA.y / LengthA;
    //_rayVector.z = VectorA.z / LengthA;
}
#endif