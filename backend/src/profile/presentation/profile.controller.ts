import { Body, Controller, Get, Patch, Req, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiExtraModels,
  ApiOkResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AccessTokenGuard } from '../../common/guards/access-token.guard';
import { ApiAuthErrors } from '../../auth/presentation/api-error-responses.decorator';
import { ProfileService } from '../application/profile.service';
import {
  ErrorResponseDto,
  PatchProfileDto,
  ProfileViewDto,
} from './profile.dto';

@ApiTags('profile')
@ApiExtraModels(ErrorResponseDto)
@ApiBearerAuth()
@UseGuards(AccessTokenGuard)
@Controller('account/profile')
export class ProfileController {
  constructor(private readonly profiles: ProfileService) {}

  @Get()
  @ApiOkResponse({ type: ProfileViewDto })
  @ApiAuthErrors(401)
  getProfile(@Req() req: { auth: { accountId: string } }) {
    return this.profiles.getProfile(req.auth.accountId);
  }

  @Patch()
  @ApiOkResponse({ type: ProfileViewDto })
  @ApiAuthErrors(400, 401, 409)
  patchProfile(
    @Req() req: { auth: { accountId: string } },
    @Body() body: PatchProfileDto,
  ) {
    return this.profiles.patchProfile(req.auth.accountId, body);
  }
}
