using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Fade : MonoBehaviour
{
    // �t�F�[�h�̎d����ݒ肷��A�j���[�V�����J�[�u
    private AnimationCurve fadeCurve;

    // ���b�ԃt�F�[�h������̂�
    [SerializeField]private float fadeTime;

    private float elapsedTime;

    // �t�F�[�h����l���i�[����ϐ�
    private float fadeValue;

    private bool fadeflag = false;
    private bool fadefin = false;

    /* ���傢�Ǝ��� */

    public delegate void ProcessDataEvent(float _data , Component _sender);
    public event ProcessDataEvent ProcessData;
    private Component dataSender;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (fadeflag)
        {
            fadeValue = fadeCurve.Evaluate(elapsedTime / fadeTime);
            // Update�̍Ō�ɃC�x���g�𔭍s����
            ProcessData?.Invoke(fadeValue, dataSender);

            elapsedTime += Time.deltaTime;
            if(elapsedTime > fadeTime)
            {
                elapsedTime = fadeTime;

                if(fadeValue == 1)
                {
                    fadeflag = true;
                    fadefin = true;
                }
            }
        }

    }

    public void SetFade(float _fade)
    {
        fadeValue = _fade;
        fadeflag = true;
    }
}
