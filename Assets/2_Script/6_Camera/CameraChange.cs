using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraChange : MonoBehaviour
{
    // �J����
    [SerializeField]
    private CinemachineVirtualCamera _virtualCamera;
    [SerializeField,Header("�f�o�b�O���[�h")]
    private bool isDebug = false;

    // �J�����̗D��x�ݒ�
    [PersistentAmongPlayMode,SerializeField]
    private int _prioraty;

    // �J�����̍ŏ��̗D��x���i�[����
    private int _defPrioraty;

    private ControlManager _controlManager;

    private ControlManager.E_GP _TypeA;
    private ControlManager.E_GP _TypeB;

    private bool isTop = false;

    private Rigidbody playerRb;
    private PlayerShadowMode shadowMode;

    private CinemachineBrain mainCamera;


    // Start is called before the first frame update
    void Start()
    {
        // �J�����̗D��x���i�[���Ă���
        _defPrioraty = _virtualCamera.m_Priority;

        _controlManager = GetComponent<ControlManager>();
        playerRb = GetComponent<Rigidbody>();
        shadowMode = GetComponent<PlayerShadowMode>();
        GameObject[] camera = GameObject.FindGameObjectsWithTag("MainCamera");
        mainCamera = camera[camera.Length - 1].GetComponent<CinemachineBrain>();
        //for (int i = 0; i < camera.Length; i++)
        //{
        //    if (camera[i].GetComponent<CinemachineBrain>() != null)
        //    {
        //    }
        //}

    }

    // Update is called once per frame
    void Update()
    {
        
        if (_controlManager.GetPressed(_TypeA))
        {
            if (!mainCamera.IsBlending)
            {
                if (!isTop)
                {
                    SetTopViewCamera();
                }
                else
                {
                    EndTopViewCamera();
                }
            }
        }
        if(!isDebug&&!shadowMode.goFire&&playerRb.velocity.sqrMagnitude!=0)
        {
            EndTopViewCamera();
        }
    }

    public void SetTopViewCamera()
    {
        _virtualCamera.m_Priority = _prioraty;
        isTop = true;
    }

    public void EndTopViewCamera()
    {
        if(shadowMode.isPause)
        {
            return;
        }
        _virtualCamera.m_Priority = _defPrioraty;
        isTop = false;
    }
    
}
