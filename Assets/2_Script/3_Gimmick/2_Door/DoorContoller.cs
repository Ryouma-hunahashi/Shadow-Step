using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorContoller : MonoBehaviour
{
    // 扉を空けられるオブジェ
    enum KEY_PERSON
    {
        PLAYER,
        ENEMY
    }

    // 扉が開く方向
    enum OPEN_PATTERN
    { 
        ONE_SIDE,
        BOTH_SIDE,
    }

    enum HINGE_MODE
    {
        OPENING,
        CLOSING,
        IDLING,
    }

    [Header("扉を開けるオブジェ")]
    [Tooltip("PLAYER:プレイヤーのみが開けれる\n" +
            "ENEMY:エネミーのみが開けれる")]
    [SerializeField] private KEY_PERSON key;

    [Header("扉が開く方向")]
    [Tooltip("ONE_SIDE:一方向のみ開く\n" +
            "BOTH_SIDE:両方向に開く")]
    [SerializeField] private OPEN_PATTERN pattern;

    [Header("扉の蝶番オブジェ")]
    [SerializeField] private GameObject[] hinges;
    [Header("扉回転量")]
    [SerializeField] private float hingeAxis = 80.0f;
    [SerializeField] private float axisSpd = 4.0f;
    private HINGE_MODE mode = HINGE_MODE.IDLING;

    private BoxCollider col;

    void Start()
    {
        if(col == null)
        {
            col = GetComponent<BoxCollider>();
            if(col == null)
            {
                Debug.LogError("扉にBoxColliderが付いていません");
                return;
            }
        }
        col.isTrigger = false;
    }

    private void OnCollisionEnter(Collision other)
    {
        switch(pattern)
        {
            case OPEN_PATTERN.ONE_SIDE:
                this.OneSideEnter(other);
                break;

            case OPEN_PATTERN.BOTH_SIDE:
                this.BothSideEnter(other);
                break;
        }
    }

    private void OneSideEnter(Collision other)
    {
        Vector3 toOtherVec;
        Quaternion toOtherRot;

        switch (key)
        {
            case KEY_PERSON.PLAYER:
                if (!other.gameObject.CompareTag("Player")) { col.isTrigger = false; }

                toOtherVec = other.transform.position-transform.position;
                toOtherVec.y = 0;
                toOtherRot = Quaternion.LookRotation(toOtherVec, Vector3.up);

                if(Quaternion.Angle(transform.rotation, toOtherRot) > 90)
                {
                    StartCoroutine(Open(other.gameObject));
                }
                break;

            case KEY_PERSON.ENEMY:
                if (!other.gameObject.CompareTag("Enemy")) { col.isTrigger = false; }

                toOtherVec = other.transform.position - transform.position;
                toOtherVec.y = 0;
                toOtherRot = Quaternion.LookRotation(toOtherVec, Vector3.up);

                if (Quaternion.Angle(transform.rotation, toOtherRot) > 90)
                {
                    StartCoroutine(Open(other.gameObject));
                }
                break;
        }
    }

    private void BothSideEnter(Collision other)
    {
        switch (key)
        {
            case KEY_PERSON.PLAYER:
                if (!other.gameObject.CompareTag("Player")) { return; }
                StartCoroutine(Open(other.gameObject));
                break;

            case KEY_PERSON.ENEMY:
                if (!other.gameObject.CompareTag("Enemy")) { return; }
                StartCoroutine(Open(other.gameObject));
                break;
        }
    }

    private void OnTriggerExit(Collider collision)
    {
        switch(key)
        {
            case KEY_PERSON.PLAYER:
                if (!collision.gameObject.CompareTag("Player")) { return; }
                StartCoroutine(Close(collision.gameObject));
                break;

            case KEY_PERSON.ENEMY:
                if (!collision.gameObject.CompareTag("Enemy")) { return; }
                StartCoroutine(Close(collision.gameObject));

                break;
        }
    }

    private IEnumerator Open(GameObject _obj)
    {
        col.isTrigger = true;

        if (mode == HINGE_MODE.OPENING) yield break;
        mode = HINGE_MODE.OPENING;

        //Debug.Log("ドア開きまーす");

        Vector3 doorForward = transform.forward;
        doorForward.y = 0;

        Vector3 toTargetVec = _obj.transform.position - transform.position;
        toTargetVec.y = 0;

        float vecDot = Vector3.Dot(doorForward.normalized, toTargetVec.normalized);
        while (mode == HINGE_MODE.OPENING)
        {
            mode = HINGE_MODE.OPENING;
            for (int i = 0; i < hinges.Length; i++)
            {
                Vector3 toCenterVec = transform.position - hinges[i].transform.position;
                toCenterVec.y = 0;
                Vector3 hingeForward = hinges[i].transform.forward;

                Quaternion hingeRot = hinges[i].transform.localRotation;
                Quaternion baseRot = Quaternion.FromToRotation(
                    vecDot > 0 ? doorForward : -doorForward,toCenterVec);

                Quaternion addRot = Quaternion.RotateTowards(hingeRot, baseRot, axisSpd*Time.deltaTime);
                
                
                hinges[i].transform.localRotation = addRot ;

                if (Quaternion.Angle(addRot, baseRot) < 1.0f)
                {
                    hinges[i].transform.localRotation = baseRot;
                    mode = HINGE_MODE.IDLING;
                }

            }
            yield return null;
        }
        //Debug.Log("ドア開き切りました～");
        yield break;
    }

    private IEnumerator Close(GameObject _obj)
    {
        col.isTrigger = false;
        if (mode == HINGE_MODE.CLOSING) yield break;
        mode = HINGE_MODE.CLOSING;

        //Debug.Log("ドア閉まりまーす");

        Vector3 doorForward = transform.forward;
        doorForward.y = 0;

        Vector3 toTargetVec = _obj.transform.position - transform.position;
        toTargetVec.y = 0;

        float vecDot = Vector3.Dot(doorForward.normalized, toTargetVec.normalized);
        while (mode == HINGE_MODE.CLOSING)
        {
            mode = HINGE_MODE.CLOSING;

            for (int i = 0; i < hinges.Length; i++)
            {
                Vector3 toCenterVec = transform.position - hinges[i].transform.position;
                toCenterVec.y = 0;


                Quaternion hingeRot = hinges[i].transform.localRotation;
                Quaternion baseRot = Quaternion.identity;//*transform.rotation;
                    //Quaternion.FromToRotation(
                    //vecDot > 0 ? doorForward : -doorForward, toCenterVec)*transform.rotation;

                Quaternion addRot = Quaternion.RotateTowards(hingeRot,baseRot,  axisSpd * Time.deltaTime);

                //Debug.Log(Quaternion.Angle(addRot, baseRot));

                hinges[i].transform.localRotation = addRot;
                if (Quaternion.Angle(addRot, baseRot) < 1.0f)
                {
                    hinges[i].transform.localRotation = baseRot;
                    mode = HINGE_MODE.IDLING;
                }

            }
            yield return null;
        }
        //Debug.Log("ドア閉まりました～");
        yield break;
    }
}
