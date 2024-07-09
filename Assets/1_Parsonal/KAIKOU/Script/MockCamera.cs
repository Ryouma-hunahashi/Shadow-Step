using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MockCamera : MonoBehaviour
{
    [Header("�ǐՂ���^�[�Q�b�g")]
    [SerializeField] private Transform target;






    [Header("�^�[�Q�b�g�Ƃ̋���")]
    [SerializeField] private float toTargetDis = 5.0f;
    [Header("�J�����̏c��]�p�x")]
    [SerializeField] private float toTargetAngle = 45.0f;
    [Header("�J�����̉���]�p�x")]
    [SerializeField] private float rotateY = 0.0f;


    [SerializeField] private ControlManager controlManager;

    [Header("�J�����ړ��ő勗��")]
    [SerializeField] private float maxMoveDis = 3.0f;
    // ���݂̈ړ�����
    private Vector3 nowMoveDis = Vector3.zero;
    [Header("�J�����ړ��Œᑬ�x")]
    [SerializeField] private float minMoveAccel = 0.2f;
    [Header("�J�����ō��ړ����x")]
    [SerializeField] private float maxMoveAccel = 1.0f;
    [Header("�J�������x")]
    [SerializeField, Range(0.01f, 1.0f)] private float sensitivity = 0.5f;
    // �J�����̊�{�ʒu���O
    private Vector3 normalPos_log = Vector3.zero;
    private Vector3 normalPos_dif;

    // Start is called before the first frame update
    void Start()
    {
        // �X�N���v�g�擾
        controlManager = GetComponent<ControlManager>();

        // �ړ������������W�̒l��ʕϐ��ɕۑ�

        CreateQuaterView();
        normalPos_log = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 nowPos = transform.position;
        CreateQuaterView();


        nowPos += normalPos_dif;
        Vector3 normalPos = transform.position;

        Vector3 stickAxis = new Vector3(controlManager.GetStickValue(ControlManager.E_DIRECTION.RIGHT).x, 0,
            controlManager.GetStickValue(ControlManager.E_DIRECTION.RIGHT).y);

        // �O�����x�N�g����X,Z�����Ԃ̊p�x����A�N�H�[�^�j�I���𐶐�
        float rad = Mathf.Atan2(transform.forward.x, transform.forward.z);
        Quaternion axisQuater = Quaternion.AngleAxis(rad * Mathf.Rad2Deg, Vector3.up);

        // �X�e�B�b�N�̈ړ�������]
        stickAxis = axisQuater * stickAxis;

        Vector3 targetPos = new Vector3(normalPos.x + stickAxis.x * maxMoveDis,
            transform.position.y,
            normalPos.z + stickAxis.z * maxMoveDis);

        float disX = targetPos.x - nowPos.x;
        float moveSpeedX = Mathf.Min((Mathf.Abs(disX)) * sensitivity, maxMoveAccel);

        float disZ = targetPos.z - nowPos.z;
        float moveSpeedZ = Mathf.Min((Mathf.Abs(disZ)) * sensitivity, maxMoveAccel);

        nowMoveDis.x = Mathf.Clamp(nowMoveDis.x + moveSpeedX * Mathf.Sign(disX), -maxMoveDis, maxMoveDis);
        nowMoveDis.z = Mathf.Clamp(nowMoveDis.z + moveSpeedZ * Mathf.Sign(disZ), -maxMoveDis, maxMoveDis);

        normalPos.x += nowMoveDis.x;
        normalPos.z += nowMoveDis.z;

        transform.position = normalPos;

    }
    /// <summary>
    /// �ݒ�A���O������N�H�[�^�[�r���[���쐬
    /// </summary>
    private void CreateQuaterView()
    {
        var rotate = Quaternion.identity;
        Vector3 pos = target.position;
        pos.y += toTargetDis;
        pos -= target.position;

        Quaternion quaterX = Quaternion.AngleAxis(-toTargetAngle, Vector3.right);
        Quaternion quaterY = Quaternion.AngleAxis(rotateY, Vector3.up);
        Quaternion quater90 = Quaternion.AngleAxis(90, Vector3.right);

        pos = quaterY * quaterX * pos;
        pos += target.position;

        transform.position = pos;
        normalPos_dif = pos - normalPos_log;
        normalPos_log = pos;

        transform.rotation = rotate * quaterY * quater90 * quaterX;
    }
}
