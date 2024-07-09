using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraControl : MonoBehaviour
{

    [Header("追跡するターゲット")]
    [SerializeField] private Transform target;


    [Header("シネマシーンの初期追従座標")]
    [SerializeField] private Vector3 initFollowPos = new Vector3(0, 2.3f, -3);

    [SerializeField] private CinemachineVirtualCamera camera;
    [SerializeField] private CinemachineTransposer transposer;


    //[Header("ターゲットとの距離")]
    //[SerializeField] private float toTargetDis = 5.0f;
    //[Header("カメラの縦回転角度")]
    //[SerializeField] private float toTargetAngle = 45.0f;
    //[Header("カメラの横回転角度")]
    //[SerializeField] private float rotateY = 0.0f;


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
    [SerializeField, Range(1.00f, 5.00f)] private float sensitivity = 1.0f;
    // カメラの基本位置ログ
    private Vector3 normalPos_log = Vector3.zero;
    private Vector3 normalPos_dif;
    private Vector3 followPos;
    private Vector3 normalFollowPos;
    private Vector3 nowPos;

    // Start is called before the first frame update
    void Start()
    {
        // スクリプト取得
        controlManager = GetComponent<ControlManager>();
        camera = GetComponent<CinemachineVirtualCamera>();
        transposer = camera.GetCinemachineComponent<CinemachineTransposer>();
        // 移動させたい座標の値を別変数に保存
        transposer.m_FollowOffset = initFollowPos;
        followPos = transposer.m_FollowOffset;
        //CreateQuaterView();
        normalFollowPos = followPos;
        normalPos_log = followPos;
    }

    //private void Update()
    //{

    //}

    // Update is called once per frame
    void /*Late*/Update()
    {
        // CreateQuaterView();
        nowPos = transposer.m_FollowOffset;
        followPos = normalFollowPos;
        normalPos_dif = transposer.m_FollowOffset - normalPos_log;

        //nowPos += normalPos_dif;
        Vector3 normalPos = followPos;

        Vector3 stickAxis = new Vector3(controlManager.GetStickValue(ControlManager.E_DIRECTION.RIGHT).x, 0,
            controlManager.GetStickValue(ControlManager.E_DIRECTION.RIGHT).y);

        // 前向きベクトルのX,Z成分間の角度から、クォータニオンを生成
        float rad = Mathf.Atan2(transform.forward.x, transform.forward.z);
        Quaternion axisQuater = Quaternion.AngleAxis(rad * Mathf.Rad2Deg, Vector3.up);

        // スティックの移動軸を回転
        stickAxis = axisQuater * stickAxis;
        float moveDisX = stickAxis.x * maxMoveDis;
        float moveDisZ = stickAxis.z * maxMoveDis;

        Vector3 targetPos = new Vector3(normalPos.x +moveDisX,
            transform.position.y,
            normalPos.z + moveDisZ);

        float disX = targetPos.x - nowPos.x;
        float disZ = targetPos.z - nowPos.z;

        // float moveSpeedX = Mathf.Min((Mathf.Abs(disX)) * sensitivity,maxMoveAccel);
        // float moveSpeedZ = Mathf.Min((Mathf.Abs(disZ)) * sensitivity,maxMoveAccel);

        Vector2 disVec = new Vector2(disX, disZ);
        disVec = disVec.sqrMagnitude <= 0.05f*0.05f ? Vector2.zero : disVec;
        float moveSpeed = Mathf.Min(Mathf.Min(disVec.magnitude*sensitivity/maxMoveDis,1.0f)*maxMoveAccel+minMoveAccel,
            maxMoveAccel);
        Vector2 normalDisVec = disVec.normalized;
        nowMoveDis.x = Mathf.Clamp(nowMoveDis.x + normalDisVec.x * moveSpeed * Time.deltaTime, -maxMoveDis, maxMoveDis);
        nowMoveDis.z = Mathf.Clamp(nowMoveDis.z + normalDisVec.y * moveSpeed * Time.deltaTime, -maxMoveDis, maxMoveDis);
        //nowMoveDis.x = Mathf.Clamp(nowMoveDis.x + moveSpeedX*Mathf.Sign(disX), -maxMoveDis,maxMoveDis);
        //nowMoveDis.z = Mathf.Clamp(nowMoveDis.z + moveSpeedZ * Mathf.Sign(disZ), -maxMoveDis,maxMoveDis);

        //if(nowMoveDis.sqrMagnitude<0.005f)
        //{
        //    nowMoveDis.x = -disX;
        //    nowMoveDis.z = -disZ;
        //}
        if (stickAxis.sqrMagnitude <= 0.03f * 0.03f && disVec ==Vector2.zero)
        {
            nowMoveDis = Vector3.zero;
        }

        normalPos.x += nowMoveDis.x;
        normalPos.z += nowMoveDis.z;
        Vector3 pos = this.transform.position;
        pos.x+= nowMoveDis.x;
        pos.z+= nowMoveDis.z;
        Vector3 tarPos = target.transform.parent.position;
        tarPos.x += nowMoveDis.x;
        tarPos.z += nowMoveDis.z;
        //Debug.Log("カメラの補正距離：" + nowMoveDis.x);

        //if(normalPos.x*normalPos.x+normalPos.z*normalPos.z<0.002)
        //{
        //    normalPos = targetPos;
        //}

        followPos = normalPos;
        //transform.position = pos;

        target.transform.position = tarPos;

        normalPos_log = transposer.m_FollowOffset;
        transposer.m_FollowOffset = followPos;

    }
    /// <summary>
    /// 設定アングルからクォータービューを作成
    /// </summary>
    //private void CreateQuaterView()
    //{
    //    var rotate = Quaternion.identity;
    //    Vector3 pos = target.position;
    //    pos.y += toTargetDis;
    //    pos -= target.position;
    //
    //    Quaternion quaterX = Quaternion.AngleAxis(-toTargetAngle, Vector3.right);
    //    Quaternion quaterY = Quaternion.AngleAxis(rotateY, Vector3.up);
    //    Quaternion quater90 = Quaternion.AngleAxis(90, Vector3.right);
    //
    //    pos = quaterY * quaterX * pos;
    //    pos += target.position;
    //
    //    followPos = pos;
    //    normalPos_dif = pos - normalPos_log;
    //    normalPos_log = pos;
    //
    //    transform.rotation = rotate * quaterY * quater90 * quaterX;
    //}
}
