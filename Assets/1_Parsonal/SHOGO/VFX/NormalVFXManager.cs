using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// VFX���g�����߂ɕK�v
using UnityEngine.VFX;
public class VFXManager : MonoBehaviour
{
    private VisualEffect effect;
    // �e�̒���
    [SerializeField]
    private float length;
    // �e�̕���
    [SerializeField]
    private Vector3 direction;
    
    // Start is called before the first frame update
    void Start()
    {
        // �I�u�W�F�N�g����VFX�R���|�[�l���g���擾
        effect = this.GetComponent<VisualEffect>();
        
    }

    // Update is called once per frame
    void Update()
    {
        // �e�̒����𑗐M
        effect.SetFloat("length", length);
        // �e�̕����𑗐M
        effect.SetVector3("Direction",direction);
        // �e�̎n�_�𑗐M
        effect.SetVector3("position", transform.position);

        //// �e�����񂾎�
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
        //    effect.SetBool("GrabFlg", false);
        //    this.gameObject.SetActive(false);

        //}
    }

}
