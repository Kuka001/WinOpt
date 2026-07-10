$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(!$isAdmin){Write-Host "Запустите от Администратора!" -ForegroundColor Red;Pause;exit}

Write-Host "Настройка схемы электропитания CS2_Optimized..." -ForegroundColor Cyan

$P = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg -restoredefaultschemes *>$null
powercfg -changename $P "CS2_Optimized" "Максимальная производительность"

function A($s,$t,$a,$d){powercfg -setacvalueindex $P $s $t $a;powercfg -setdcvalueindex $P $s $t $d}

Write-Host "Применение параметров..." -ForegroundColor Yellow

$s="fea3413e-7e05-4911-9a71-700331f1c294"
A $s 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 0 0;A $s 245d8541-3943-4422-b025-13a784f679b7 1 1;A $s 4faab71a-92e5-4726-b531-224559672d19 0 0;A $s 68afb2d9-ee95-47a8-8f50-4115088073b1 0 0;A $s f15576e8-98b7-4186-b944-eafa664402d9 1 1

$s="0012ee47-9041-4b5d-9b77-535fba8b1442"
foreach($g in @("0b2d69d7-a2a1-449c-9680-f91c70521c60","6738e2c4-e8a5-4a42-b16a-e040e769756e","80e3c60e-bb94-4ad8-bbe0-0d3195efc663","d3d55efd-c1ff-424e-9dc3-441be7833010","d639518a-e56d-4345-8af2-b9f32fb26109","dab60367-53fe-4fbc-825e-521d069d2456","dbc9e238-6de9-49e3-92cd-8c2b4946b472","fc7372b6-ab2d-43ee-8797-15e9841f2cca","fc95af4d-40e7-4b6d-835a-56d131dbc80e")){A $s $g 0 0}
A $s 51dea550-bb38-4bc4-991b-eacf37be5ec8 100 100

A "02f815b5-a5cf-4c84-bf20-649d1f75d3d8" 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1 1
A "0d7dbae2-4294-402a-ba8e-26777e8488cd" 309dce9b-bef4-4119-9921-a851fb12f0f4 1 1
A "19cbb8fa-5279-450e-9fac-8a3d5fedd0c1" 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 0

$s="238c9fa8-0aad-41ed-83f4-97be242c8f20"
A $s 1a34bdc3-7e6b-442e-a9d0-64b6ef378e84 1 0;A $s 25dfa149-5dd1-4736-b5ab-e8a37b5b8187 0 0;A $s 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 600 240
foreach($g in @("7bc4a2f9-d8fc-4469-b07b-33eb785aaca0","94ac6d29-73ce-41a6-809f-6363ba21b47e","9d7815a6-7ee4-497e-8888-515a05f02364","abfc2519-3608-4c2a-94ea-171b0ed546ab","bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d","d4c1d4c8-d5cc-43d3-b83e-fc51215cb04d")){A $s $g 0 0}
A $s a4b195f5-8225-47d8-8012-9d41369786e2 1 1

$s="2a737441-1930-4402-8d77-b2bebba308a3"
foreach($g in @("0853a681-27c8-4100-a2fd-82013e970683","48e6b7a6-50f5-4782-a5d4-53bb8f07e226","d4e98f31-5ffe-4ce1-be31-1b38b384c009")){A $s $g 0 0}
A $s 498c044a-201b-4631-a522-5c744ed4e678 1 1

$s="2e601130-5351-4d9d-8e04-252966bad054"
foreach($g in @("3166bc41-7e98-4e03-b34e-ec0f5f2b218e","c42b79aa-aa3a-484b-a98f-2cf32aa90a28","d502f7ee-1dc7-4efd-a55d-f04b6f5c0545")){A $s $g 0 0}
A $s c36f0eb4-2988-4a70-8eee-0884fc2c2433 50 50

$s="48672f38-7a9a-4bb2-8bf8-3d85be19de4e"
A $s 2bfc24f9-5ea2-4801-8213-3dbae01aa39d 4 4
foreach($g in @("73cde64d-d720-4bb2-a860-c755afe77ef2","d6ba4903-386f-4c2c-8adb-5c21b3328d25")){A $s $g 0 0}

$s="4f971e89-eebd-4455-a8de-9e59040e7347"
foreach($g in @("5ca83367-6e45-459f-a27b-476b1d01c936","7648efa3-dd9c-4e3e-b566-50f929386280","833a6b62-dfa4-46d1-82f8-e09e34d029d6","96996bc0-ad50-47ec-923b-6f41874dd9eb","99ff10e7-23b1-4c07-a9d1-5c3206d741b4")){A $s $g 0 0}
A $s a7066653-8d6c-40a8-910e-a1f54b84c7e5 2 2

A "501a4d13-42af-4429-9fd1-a8218c268e20" ee12f906-d277-404b-b6da-e5fa1a576df5 0 0

$s="54533251-82be-4824-96c1-47b60b740d00"
$cpuSettings = @(
"06cadf0e-64ed-448a-8927-ce7bf90eb35d,1","06cadf0e-64ed-448a-8927-ce7bf90eb35e,1",
"0cc5b647-c1df-4637-891a-dec35c318583,100","0cc5b647-c1df-4637-891a-dec35c318584,100",
"12a0ab44-fe28-4fa9-b3bd-4b64f44960a6,0","12a0ab44-fe28-4fa9-b3bd-4b64f44960a7,0",
"1a98ad09-af22-42ca-8e61-f0a5802c270a,0","1facfc65-a930-4bc5-9f38-504ec097bbc0,100",
"2430ab6f-a520-44a2-9601-f7f23b5134b1,100","2ddd5a84-5a71-437e-912a-db0b8c788732,1",
"36687f9e-e3a5-4dbf-b1dc-15eb381c6863,0","36687f9e-e3a5-4dbf-b1dc-15eb381c6864,0",
"3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb,0","4009efa7-e72d-4cba-9edf-91084ea8cbc3,1",
"40fbefc7-2e9d-4d25-a185-0cfd8574bac6,2","40fbefc7-2e9d-4d25-a185-0cfd8574bac7,2",
"43f278bc-0f8a-46d0-8b31-9a23e615d713,0","447235c7-6a8d-4cc0-8e24-9eaf70b96e2b,2",
"447235c7-6a8d-4cc0-8e24-9eaf70b96e2c,2","45bcc044-d885-43e2-8605-ee0ec6e96b59,100",
"465e1f50-b610-473a-ab58-00d1077dc418,2","465e1f50-b610-473a-ab58-00d1077dc419,2",
"4b70f900-cdd9-4e66-aa26-ae8417f98173,100","4b70f900-cdd9-4e66-aa26-ae8417f98174,100",
"4b92d758-5a24-4851-a470-815d78aee119,1","4b92d758-5a24-4851-a470-815d78aee11a,1",
"4bdaf4e9-d103-46d7-a5f0-6280121616ef,0","4d2b0152-7d5c-498b-88e2-34345392a2c5,5000",
"4e4450b3-6179-4e91-b8f1-5bb9938f81a1,0","53824d46-87bd-4739-aa1b-aa793fac36d6,0",
"5d76a2ca-e8c0-402f-a133-2158492d58ad,0","603fe9ce-8d01-4b48-a968-1d706c28fd5c,100",
"603fe9ce-8d01-4b48-a968-1d706c28fd5d,100","60fbe21b-efd9-49f2-b066-8674d8e9f423,0",
"616cdaa5-695e-4545-97ad-97dc2d1bdd88,100","616cdaa5-695e-4545-97ad-97dc2d1bdd89,100",
"619b7505-003b-4e82-b7a6-4dd29c300971,100","619b7505-003b-4e82-b7a6-4dd29c300972,100",
"64fcee6b-5b1f-45a4-a76a-19b2c36ee290,1","6788488b-1b90-4d11-8fa7-973e470dff47,100",
"69439b22-221b-4830-bd34-f7bcece24583,100","6c2993b0-8f48-481f-bcc6-00dd2742aa06,0",
"6ff13aeb-7897-4356-9999-dd9930af065f,1","71021b41-c749-4d21-be74-a00f335d582b,1",
"75b0ae3f-bce0-45a7-8c89-c9611c25e100,0","75b0ae3f-bce0-45a7-8c89-c9611c25e101,0",
"7b224883-b3cc-4d79-819f-8374152cbe7c,0","7d24baa7-0b84-480f-840c-1b0743c00f5f,1",
"7d24baa7-0b84-480f-840c-1b0743c00f60,1","7f2492b6-60b1-45e5-ae55-773f8cd5caec,1",
"7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5,0","828423eb-8662-4344-90f7-52bf15870f5a,0",
"893dee8e-2bef-41e0-89c6-b55d0929964c,100","893dee8e-2bef-41e0-89c6-b55d0929964d,100",
"8baa4a8a-14c6-4451-8e8b-14bdbd197537,0","93b8b6dc-0698-4d1c-9ee4-0644e900c85d,5",
"943c8cb6-6f93-4227-ad87-e9a3feec08d1,5","94d3a615-a899-4ac5-ae2b-e4d8f634367f,1",
"97cfac41-2217-47eb-992d-618b1977c907,0","984cf492-3bed-4488-a8f9-4286c97bf5aa,1",
"984cf492-3bed-4488-a8f9-4286c97bf5ab,1","9943e905-9a30-4ec1-9b99-44dd3b76f7a2,0",
"b000397d-9b0b-483d-98c9-692a6060cfbf,255","b000397d-9b0b-483d-98c9-692a6060cfc0,255",
"b0deaf6b-59c0-4523-8a45-ca7f40244114,1","b28a6829-c5f7-444e-8f61-10e24e85c532,0",
"b669a5e9-7b1d-4132-baaa-49190abcfeb6,1","bae08b81-2d5e-4688-ad6a-13243356654b,5",
"bc5038f7-23e0-4960-96da-33abaf5935ec,100","bc5038f7-23e0-4960-96da-33abaf5935ed,100",
"be337238-0d82-4146-a960-4f3749d470c7,2","bf903d33-9d24-49d3-a468-e65e0325046a,0",
"c4581c31-89ab-4597-8e2b-9c9cab440e6b,200000","c7be0679-2817-4d69-9d02-519a537ed0c6,2",
"cfeda3d0-7697-4566-a922-a9086cd49dfa,0","d8edeb9b-95cf-4f95-a73c-b061973693c8,1",
"d8edeb9b-95cf-4f95-a73c-b061973693c9,1","d92998c2-6a48-49ca-85d4-8cceec294570,0",
"dfd10d17-d5eb-45dd-877a-9a34ddd15c82,1","e0007330-f589-42ed-a401-5ddb10e785d3,0",
"ea062031-0e34-4ff1-9b6d-eb1059334028,100","ea062031-0e34-4ff1-9b6d-eb1059334029,100",
"f735a673-2066-4f80-a0c5-ddee0cf1bf5d,100","f8861c27-95e7-475c-865b-13c0cb3f9d6b,255",
"f8861c27-95e7-475c-865b-13c0cb3f9d6c,255","fddc842b-8364-4edc-94cf-c17f60de1c80,100"
)
foreach($item in $cpuSettings){$parts=$item.Split(',');A $s $parts[0] ([int]$parts[1]) ([int]$parts[1])}

A "5fb4938d-1ee8-4b0f-9a3c-5036b0ab995c" dd848b2a-8a5d-4451-9ae2-39cd41658f6c 0 0

$s="7516b95f-f776-4464-8c53-06167f40cc99"
foreach($g in @("17aaa29b-8b43-4b94-aafe-35f64daaf1ee","3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e","8ec4b3a5-6868-48c2-be75-4f3044be88a7","90959d22-d6a1-49b9-af93-bce885ad335b","fbd9aa66-9553-4097-ba44-ed6e9d65eab8")){A $s $g 0 0}
A $s 684c3e69-a4f7-4014-8754-d45179a56167 1 1;A $s a9ceb8da-cd46-44fb-a98b-02af69de4623 1 1
A $s aded5e82-b909-4619-9949-f5d71dac0bcb 100 100;A $s f1fbfde2-a960-4165-9f88-50667911ce96 100 100

$s="8619b916-e004-4dd8-9b66-dae86f806698"
foreach($g in @("0a7d6ab6-ac83-4ad1-8282-eca5b58308f3","468fe7e5-1158-46ec-88bc-5b96c9e44fd0","49cb11a5-56e2-4afb-9d38-3df47872e21b","5adbbfbc-074e-4da1-ba38-db8b36b2c8f3","60c07fe1-0556-45cf-9903-d56e32210242","61f45dfe-1919-4180-bb46-8cc70e0b38f1","82011705-fb95-4d46-8d35-4042b1d20def","9fe527be-1b70-48da-930d-7bcf17b44990","a79c8e0e-f271-482d-8f8a-5db9a18312de","aca8648e-c4b1-4baa-8cce-9390ad647f8c","c763ee92-71e8-4127-84eb-f6ed043a3e3d","cf8c6097-12b8-4279-bbdd-44601ee5209d","ee16691e-6ab3-4619-bb48-1c77c9357e5a")){A $s $g 0 0}

$s="9596fb26-9850-41fd-ac3e-f7c3c00afd4b"
A $s 03680956-93bc-4294-bba6-4e0f09bb717f 1 1;A $s 10778347-1370-4ee0-8bbd-33bdacaade49 1 1;A $s 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0 0

A "c763b4ec-0e50-4b6b-9bed-2b92a6ee884e" 7ec1751b-60ed-4588-afb5-9819d3d77d90 3 3

$s="de830923-a562-41af-a086-e3a2c6bad2da"
foreach($g in @("13d09884-f74e-474a-a852-b6bde8ad03a8","5c5bb349-ad29-4ee2-9d0b-2b25270f7a81","e69653ca-cf7f-4f05-aa73-cb833fa90ad4")){A $s $g 0 0}
A "e276e160-7cb0-43c6-b20b-73f5dce39954" a1662ab2-9d34-4e53-ba8b-2639b9e20857 2 1

$s="e73a048d-bf27-4f12-9731-8b2076e8891f"
foreach($g in @("5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f","637ea02f-bbcb-4015-8e2c-a1c7b9c0b546","8183ba9a-e910-48da-8769-14ae6dc1170a","9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469","bcded951-187b-4d05-bccc-f7e51960c258","d8742dcb-3e6a-4b3c-b3fe-374623cdcf06","f3c5027d-cd16-4930-aa6b-90db844a8f00")){A $s $g 0 0}

A "f693fb01-e858-4f00-b20f-f30e12ac06d6" 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 1 1

powercfg -setactive $P
Write-Host "Удаление других планов..." -ForegroundColor Yellow
foreach($line in (powercfg -list)){
    if($line -match "([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})"){
        if($matches[1] -ne $P){powercfg -delete $matches[1] *>$null}
    }
}
Write-Host "ГОТОВО! CS2_Optimized активирована." -ForegroundColor Green