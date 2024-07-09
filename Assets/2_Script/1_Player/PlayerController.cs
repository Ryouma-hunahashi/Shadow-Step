using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    /* 視点毎の操作方法の変更 */
    [System.Serializable]
    private enum E_VIEWPOINT
    {
        TOPDOWN,        // 俯瞰視点操作
        FIRST_PERSON,   // 一人称視点操作
        THIRD_PERSON,   // 三人称視点操作
        SIDESCROLLING,  // 横スクロール操作
    }

    [System.Serializable]
    private struct s_CONTROL
    {
        public ControlManager Main;

        public ControlManager.E_DIRECTION Direction;
        public float ZR_DeadZone;
        public bool nowTri;
        public bool logTri;

    }

    [System.Serializable]
    private struct s_SpeedDecrease
    {
        /* 影保有時の速度減少設定 */
        public float MaxRate;
        public float MinRate;

        public float Speed;
    }

    /* 移動操作用のスティック詳細設定 */
    [System.Serializable]
    private struct S_StickSetting
    {
        // 使用状態の確認用
        public bool isUse;

        /* 移動速度とデッドゾーンの設定 */
        public float Speed;
        [Range(0.0f, 1.0f)] public float DeadZone;
    }

    /* 移動操作用の設定 */
    [System.Serializable]
    private struct S_Movement
    {
        public S_StickSetting First;
        public S_StickSetting Middle;
        public S_StickSetting Last;
    }

    [SerializeField] s_SpeedDecrease[] m_Decrease;

    [SerializeField] private E_VIEWPOINT m_ViewPoint;
    [SerializeField, Range(0f, 10f)] float m_Sensitivity;

    [SerializeField] private bool m_AccStick = false;
    
    [SerializeField] private s_CONTROL m_Control;


    [Header("移動関連の設定")]
    [SerializeField] private S_Movement m_Movement;
    [SerializeField] private float m_NormalSpeed;
    private float m_VariableSpeed = 0.0f;

    public bool GetMovementStickLevel(int _num)
    {
        switch(_num)
        {
            case 0:
                return m_Movement.First.isUse;
            case 1:
                return m_Movement.Middle.isUse;
            case 2:
                return m_Movement.Last.isUse;
            default:
                Debug.Log("値指定に不備があります");
                return false;
        }

        return false;
    }

    [SerializeField] private float m_SpeedDecreaseRate;

    [SerializeField] private Rigidbody m_Rb;

    [SerializeField] private PlayerShadowMode m_ShadowMode;

    [SerializeField] private bool m_DiagonalMovement;

    [SerializeField] private bool isMove;

    [SerializeField] private float test;

    public void SetMoveSpeed(float _spd) { m_VariableSpeed = _spd; }

    private void Start()
    {
        m_Rb = this.GetComponent<Rigidbody>();
        m_Control.Main = this.GetComponent<ControlManager>();

        m_VariableSpeed = m_NormalSpeed;
    }

    private void Update()
    {
        // 影の保持遷移処理
        HoldShadowControl();

        // 影の保持時間で移動を制限する
        RestrictMovement();

        /* 視点設定による移動方法の変化 */
        switch(m_ViewPoint)
        {
            case E_VIEWPOINT.TOPDOWN:
                TopDownMove();
                break;
            case E_VIEWPOINT.FIRST_PERSON:
                FirstPersonMove();

                break;
            case E_VIEWPOINT.THIRD_PERSON:
                ThirdPersonMove();

                break;
            case E_VIEWPOINT.SIDESCROLLING:
                SideScrollingMove();
                break;
        }

        return;
    }

    /* 影の保持遷移処理 */
    private void HoldShadowControl()
    {
        // 影のヒット状態を出力する
        //Debug.Log(m_ShadowMode.shadowHit);

        /* 基本となる影の処理がここに付与されているなら */
        if (m_ShadowMode != null && m_ShadowMode.shadowHit)
        {
            /* コントローラ―トリガーの"押された"状態を回収する */
            if (m_Control.Main.GetTriggerSqueeze(m_Control.Direction, m_Control.ZR_DeadZone))
            {
                /* 現在と前回のトリガー状態が同じなら */
                if (m_Control.nowTri == m_Control.logTri)
                {
                    // トリガーの取得状態を変更する
                    m_Control.nowTri = !m_Control.nowTri;

                    /* 現トリガーが稼働していないなら */
                    if(!m_Control.nowTri)
                    {
                        /* 変動する速度の値を初期化する */
                        m_VariableSpeed = m_NormalSpeed;
                    }
                }
            }
            else
            {
                // トリガー状態を抜けたことを伝える
                m_Control.logTri = m_Control.nowTri;
            }

            // 影掴みを開始するかの設定を行う
            m_ShadowMode.SetShadow(m_Control.nowTri);

        }
    }

    /* 影の保持時間によって移動を制限する処理 */
    private void RestrictMovement()
    {
        /* 現トリガーが稼働しているとき */
        if(m_Control.nowTri)
        {
            /* 動いていないなら処理を抜ける */
            if (!isMove) return;

            m_SpeedDecreaseRate += (test / 100);

            m_VariableSpeed = m_VariableSpeed - (Time.deltaTime * m_SpeedDecreaseRate);

            /* 変動速度が０未満になったとき */
            if(m_VariableSpeed < 0)
            {
                // ０で固定する
                m_VariableSpeed = 0;
                m_SpeedDecreaseRate = 0;
            }
        }
    }

    /* スティック操作の斜め移動をはじく処理 */
    private Vector2 ExcludeDiagonalMovements(Vector2 _input)
    {
        /* 比較用の数値 */
        float ho = _input.x;
        float ve = _input.y;

        // 出力用の数値
        Vector2 output = _input;

        /* Verticalが設定されているなら */
        if(ve != 0)
        {
            // 水平方向へ移動はしない
            output.x = 0;
        }

        return output;
    }

    /* スティック入力を返す処理 */
    private Vector2 GetStickValue_Vec2(ControlManager.E_DIRECTION _dir,S_StickSetting _MovSet)
    {
        /* 移動入力値 */
        float movH = 0.0f;
        float movV = 0.0f;

        /* スティック入力値の設定 */
        movH = (float)m_Control.Main.GetStickIntegerValue(_dir, ControlManager.E_COORDINATE.HORIZONTAL, _MovSet.DeadZone);
        movV = (float)m_Control.Main.GetStickIntegerValue(_dir, ControlManager.E_COORDINATE.VERTICAL, _MovSet.DeadZone);

        movH *= _MovSet.Speed;
        movV *= _MovSet.Speed;

#if UNITY_EDITOR

        /* 入力された値が０でなければ */
        if(new Vector2(movH, movV) != Vector2.zero)
        {
            /* 使用状態を更新する */
            if (_MovSet.DeadZone == m_Movement.First.DeadZone) m_Movement.First.isUse = true;
            if (_MovSet.DeadZone == m_Movement.Middle.DeadZone) m_Movement.Middle.isUse = true;
            if (_MovSet.DeadZone == m_Movement.Last.DeadZone) m_Movement.Last.isUse = true;
        }

#endif

        return new Vector2(movH, movV);
    }

    /* スティックの角度によって返す値を変化させる */
    private Vector2 GetMoveSpeed()
    {
        Vector2 movStick = new Vector2(0.0f, 0.0f);

        /* 一括で使用状態を解除する */
        m_Movement.First.isUse     = false;
        m_Movement.Middle.isUse    = false;
        m_Movement.Last.isUse      = false;

        if (movStick == Vector2.zero) movStick = GetStickValue_Vec2(ControlManager.E_DIRECTION.LEFT, m_Movement.Last);
        if (movStick == Vector2.zero) movStick = GetStickValue_Vec2(ControlManager.E_DIRECTION.LEFT, m_Movement.Middle);
        if (movStick == Vector2.zero) movStick = GetStickValue_Vec2(ControlManager.E_DIRECTION.LEFT, m_Movement.First);

        return movStick;
    }

    /* 俯瞰視点用の動作を処理する */
    private void TopDownMove()
    {
        /* 移動入力値 */
        Vector2 movStick = GetMoveSpeed();

        /* 移動方向Hに合わせて向きを変更する */
        if (movStick.x > 0)
        {
            // Y軸を中心として９０度回転させる
            transform.rotation = Quaternion.Euler(0, 90, 0);
        }
        else if (movStick.x < 0)
        {
            // Y軸を中心として２７０度回転させる
            transform.rotation = Quaternion.Euler(0, 270, 0);
        }
        /* 移動方向Vに合わせて向きを変更する */
        else if (movStick.y > 0)
        {
            // Y軸を中心として０度回転させる
            transform.rotation = Quaternion.Euler(0, 0, 0);
        }
        else if (movStick.y < 0)
        {
            // Y軸を中心として18０度回転させる
            transform.rotation = Quaternion.Euler(0, 180, 0);
        }

        // 基本の移動を実行する
        m_Rb.velocity = new Vector3(m_VariableSpeed * movStick.x, 0, m_VariableSpeed * movStick.y);
    }

    /* 一人称視点での動作を処理する */
    private void FirstPersonMove()
    {
        /* 移動入力値 */
        Vector2 movStick = GetMoveSpeed();

        float lookDirH = (float)m_Control.Main.GetStickValue(ControlManager.E_DIRECTION.RIGHT,ControlManager.E_COORDINATE.HORIZONTAL);
        float lookDirV = (float)m_Control.Main.GetStickValue(ControlManager.E_DIRECTION.RIGHT, ControlManager.E_COORDINATE.VERTICAL);
        Vector3 movDir = transform.right * (movStick.x * m_VariableSpeed) + transform.forward * (movStick.y * m_VariableSpeed);

        if(m_Sensitivity != 0)
        {
            lookDirH = (m_Sensitivity * 10) * lookDirH;
            lookDirV = (m_Sensitivity * 10) * lookDirV;
        }

        transform.Rotate(Vector3.up * lookDirH);
        transform.Rotate(Vector3.left * lookDirV);

        m_Rb.velocity = movDir;
    }

    /* 三人称視点での動作を処理する */
    private void ThirdPersonMove()
    {
        /* カメラの方向ベクトルを取得する */
        Vector3 camForward = Camera.main.transform.forward;
        Vector3 camRight = Camera.main.transform.right;
        Quaternion cameraRotate = Camera.main.transform.rotation;

        /* 移動入力値 */
        Vector2 movStick = GetMoveSpeed();

        if (m_DiagonalMovement) movStick = ExcludeDiagonalMovements(movStick);

        /* 移動方向の設定 */
        Vector3 tr = camRight * (movStick.x * m_VariableSpeed);
        Vector3 tf = camForward * (movStick.y * m_VariableSpeed);
        Vector3 movDir = tr + tf;

        /* 自身が移動しているなら */
        if (movDir != new Vector3(0.0f, 0.0f, 0.0f))
        {
            Quaternion targetRotation = Quaternion.identity;

            if (movStick.x != 0)
            {
                targetRotation = Quaternion.LookRotation(tr);
            }

            if (movStick.y != 0)
            {
                targetRotation = Quaternion.LookRotation(tf);
            }

            transform.rotation = Quaternion.identity * targetRotation;

            isMove = true;
        }
        else
        {
            isMove = false;
        }

        /* 移動関連の更新を行う */
        m_Rb.velocity = movDir;

        // 自身の位置情報
        Vector3 origin = this.transform.position;

        /* 自身の前方と右側を取得する */
        Vector3 dirForward = this.transform.forward;

        Debug.DrawRay(origin, dirForward * 12.0f, Color.green);

        return;
    }

    /* 横スクロール用の動作を処理する */
    private void SideScrollingMove()
    {
        float movH;

        if(m_AccStick)
        {
            movH = (float)m_Control.Main.GetStickValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.HORIZONTAL);
        }
        else
        {
            movH = (float)m_Control.Main.GetStickIntegerValue(ControlManager.E_DIRECTION.LEFT, ControlManager.E_COORDINATE.HORIZONTAL, m_Movement.First.DeadZone);
        }

        // 基本の移動を実行する
        m_Rb.velocity = new Vector3(m_VariableSpeed * movH, 0, 0);
    }
}
