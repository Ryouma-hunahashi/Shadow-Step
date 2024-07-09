using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class GrabVFXManager : MonoBehaviour
{
    [SerializeField, Tooltip("�v���C���[�I�u�W�F�N�g")]
    GameObject playerObj;
    [SerializeField, Tooltip("����VFX�I�u�W�F�N�g�ɑΉ����Ă���G�I�u�W�F�N�g")]
    GameObject enemyObj;
    private VisualEffect effect;

    // Start is called before the first frame update
    void Start()
    {
        effect=GetComponent<VisualEffect>();
        // �Q�[���J�n���͒�~���Ă���
        effect.SetBool("GrabFlg", false);
    }

    // Update is called once per frame
    void Update()
    {
        // �G�̍��W�𑗐M
        effect.SetVector3("EnemyPos",enemyObj.transform.position);
        // �v���C���[�̍��W�𑗐M
        effect.SetVector3("PlayerPos",playerObj.transform.position);
        

        //// �e��͂񂾂Ƃ�
        //if()
        //{
        //    effect.SetBool("GrabFlg", true);
        //}
        //// �e�𗣂��Ƃ�
        //if()
        //{
        //    effect.SetBool("GrabFlg", false);
        //}
        //// �e�������Ƃ�
        //if ()
        //{
        //    this.gameObject.SetActive(true);
        //}
    }
}
