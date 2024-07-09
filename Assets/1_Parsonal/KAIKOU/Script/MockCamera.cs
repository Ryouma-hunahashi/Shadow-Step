using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MockCamera : MonoBehaviour
{
    [Header("追跡するターゲット")]
    [SerializeField] private Transform target;






    [Header("ターゲットとの距離")]
    [SerializeField] private float toTargetDis = 5.0f;
    [Header("カメラの縦回転角度")]
    [SerializeField] private float toTargetAngle = 45.0f;
    [Header("カメラの横回転角度")]
    [SerializeField] private float rotateY = 0.0f;


    [SerializeField] private ControlManager controlManager;

    [Header("カメラ移動最大距離")]
    [SerializeField] private float maxMoveDis = 3.0f;
    // 現在の移動距離
    private Vector3 nowMoveDis = Vector3.zero;
    [Header("カメラ移動最低速度")]
    [SerializeField] private float minMoveAccel = 0.2f;
    [Header("カメラ最高移動速度")]
    [SerializeField] private float maxMoveAccel = 1.0f;
    [Header("カメラ感度")]
    [SerializeField, Range(0.01f, 1.0f)] private float sensitivity = 0.5f;
    // カメラの基本位置ログ
    private Vector3 normalPos_log = Vector3.zero;
    private Vector3 normalPos_dif;

    // Start is called before the first frame update
    void Start()
    {
        // スクリプト取得
        controlManager = GetComponent<ControlManager>();

        // 移動させたい座標の値を別変数に保存

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

        // 前向きベクトルのX,Z成分間の角度から、クォータニオンを生成
        float rad = Mathf.Atan2(transform.forward.x, transform.forward.z);
        Quaternion axisQuater = Quaternion.AngleAxis(rad * Mathf.Rad2Deg, Vector3.up);

        // スティックの移動軸を回転
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
    /// 設定アングルからクォータービューを作成
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
