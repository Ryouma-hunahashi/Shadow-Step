#ifndef SAMPLE_HEXAGON_INCLUDED
#define SAMPLE_HEXAGON_INCLUDED

void _GenerateHexagon_float(
in float2 _uv,
in float _scale,
out float _hexagon,
out float2 _hexPos,
out float2 _hexUV,
out float2 _hexIndex
)
{
    _hexPos = float2(0, 0);
    _hexUV = float2(0, 0);
    _hexIndex = float2(0, 0);
    
    float2 p = _uv * _scale;
    p.x *= 1.15470053838;
    float isTwo = frac(floor(p.x) / 2.0) * 2.0; // ������ڂȂ�1.0
    float isOne = 1.0 - isTwo; // ���ڂȂ�1.0
    p.y += isTwo * 0.5; // ������ڂ�0.5���炷
    float2 rectUV = frac(p); // �l�p�`�^�C��
    float2 grid = floor(p); // �l�p�`�O���b�h
    p = frac(p) - 0.5;
    float2 s = sign(p); // �}�X�ڂ̉E��:(+1, +1) ����:(-1, +1) �E��:(+1, -1) ����:(-1, -1)
    p = abs(p); // �㉺���E�Ώ̂ɂ���
            // �Z�p�`�^�C���Ƃ��ďo��
    _hexagon = abs(max(p.x * 1.5 + p.y, p.y * 2.0) - 1.0);
            
    float isInHex = step(p.x * 1.5 + p.y, 1.0); // �Z�p�`�̓����Ȃ�1.0
    float isOutHex = 1.0 - isInHex; // �Z�p�`�̊O���Ȃ�1.0
            // �l�p�`�}�X�̂����A�Z�p�`�̊O���̕�����␳���邽�߂Ɏg�p����l
    float2 grid2 = float2(0, 0);
            // ������ڂƊ��ڂ𓯎��ɉ��H
    grid2 = lerp(
                float2(s.x, +step(0.0, s.y)), // ���� (isTwo=0.0�̏ꍇ�͂�������̗p)
                float2(s.x, -step(s.y, 0.0)), // ������� (isTwo=1.0�̏ꍇ�͂�������̗p)
                isTwo) * isOutHex; // �Z�p�`�̊O���������o��
            // �Z�p�`�̔ԍ��Ƃ��ďo��
    _hexIndex = grid + grid2;
            // �Z�p�`�̍��W�Ƃ��ďo��
    _hexPos = _hexIndex / _scale;
            // �Z�p�`�̓����Ȃ�rectUV�A�O���Ȃ�4�̘Z�p�`��UV���g��
    _hexUV = lerp(rectUV, rectUV - s * float2(1.0, 0.5), isOutHex);
       
}
#endif